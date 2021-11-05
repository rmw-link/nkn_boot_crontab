#!/usr/bin/env coffee

import Pool from './pool.coffee'
import string2compact from 'string2compact'
import compact2string from 'compact2string'
#import os from 'os'
import {promisify} from 'util'
import nkn from 'nkn-sdk'
import path from 'path'
import Database from 'better-sqlite3'
import fs from 'fs/promises'
import {randomBytes} from 'crypto'

root = path.dirname path.dirname new URL(import.meta.url).pathname
#await fs.mkdir(root, recursive: true)


fakeAddress = =>
  #seedLen = 32
  #seed = randomBytes(seedLen)
  #key = sodium.crypto_sign_seed_keypair seed
  #console.log key.publicKey.length
  #Buffer.from(key.publicKey).toString('hex')
  Buffer.from(randomBytes(32)).toString('hex')


now = =>
  parseInt new Date() / 1000


do =>
  db = new Database(
    path.join(root,'data/ip.db')
    {
      #verbose: console.log
    }
  )
#db.pragma('journal_mode = WAL')
  db.exec(await fs.readFile(path.join(root,'ip.sql'),'utf8'))

  host_ok = db.prepare "INSERT INTO nkn_boot (addr,delay) VALUES(?,?) ON CONFLICT(addr) DO UPDATE SET ok=excluded.ok+1,delay=(excluded.delay+delay)/2,rank=(100000*(ok+100)/(100+ok+err))/delay,utime=?"

  host_err = db.prepare "UPDATE nkn_boot SET ok=ok-1,err=err+1,rank=rank/2 WHERE id=?"

  verfiy = (ip_port)=>
    begin = new Date() - 0

    {rpcAddr} = await nkn.rpc.getWsAddr(fakeAddress(), rpcServerAddr:"http://#{ip_port}")

    delay = (new Date() - begin)

    if /^\d+\.\d+\.\d+\.\d+\:\d+$/.test(rpcAddr)
      console.log ip_port, host_ok.run(string2compact(ip_port), delay, parseInt(begin/1000))

    rpcAddr

  li = db.prepare("select id,addr from nkn_boot where utime<? or rank=0").all(now()-86400)
  n = li.length

  if n == 0
    ip_port = "159.203.149.242:30003"
    loop
      try
        ip_port = await verfiy ip_port
        ++n
      catch
        break

  pool = new Pool(128)

  refresh = ({id,addr})=>
    loop
      ip_port = compact2string(addr)
      try
        ip_port = await verfiy ip_port
      catch err
        console.log "❌",id,ip_port,err
        host_err.run id
        continue
      console.log n
      if n > 2048 or (++n) % 5 == 0
        break

  for i from li
    await pool.add refresh i

  await pool.all()
  db.exec("DELETE FROM nkn_boot where ok<=0;VACUUM;")

  li = []
  for {addr} from db.prepare("select addr from nkn_boot order by rank desc,id asc limit 128").iterate()
    li.push compact2string(addr)

  await fs.writeFile(
    path.join(root,"data/ip")
    string2compact.multi(li)
  )

  process.exit()











