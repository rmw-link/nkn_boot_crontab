export default class Pool
  constructor:(@n=10)->
    @now = 0

  add:(p)=>
    new Promise (resolve)=>
      ++@now
      #console.log "++now", @now
      if @now < @n
        resolve()
      else
        @next = resolve
      p.finally =>
        n = --@now
        #console.log "--now", @now
        {next} = @
        if next
          delete @next
          next()
        if n == 0
          {done} = @
          if done
            delete @done
            done()

  all:=>
    new Promise (resolve)=>
      @done = resolve
