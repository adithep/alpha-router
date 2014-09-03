ses.current_path_n = new Blaze.ReactiveVar()
ses.current_path_arr = new Blaze.ReactiveVar()
ses.path = new ReactiveDict()
ses.tem = {}


Deps.autorun ->
  b = ses.current_path_arr.get()
  if b and b.length > 0
    n = 0
    while n < b.length
      i = 0
      while i < b[n].length
        te = "#{n}:#{i}"
        unless ses.path.equals(te, b[n][i])
          ses.path.set(te, b[n][i])
        i++
      n++
    ses.path.set(n, false)
  return

Deps.autorun ->
  if Session.equals("subscription", true)
    root = DATA.findOne(_s_n: "apps")
    if root and root.app_dis
      document.title = root.app_dis
    return

Deps.autorun ->
  DATA.find(_s_n: "templates").observe

    added: (doc) ->

      ses.tem[doc.tem_ty_n] = new Blaze.ReactiveVar(doc)

    changed: (ndoc) ->
      ses.tem[doc.tem_ty_n].set(ndoc)

    removed: (doc) ->

      delete ses.tem[doc.tem_ty_n]


slash = (str, pparr) ->
  n = 0
  i = 0
  bct = 0
  parr = pparr or [0]
  arr = []
  while n < str.length
    if str[n] is "("
      bct++
      if arr[i]
        if /[():]/.test(arr[i])
          parr[parr.length] = 0
          bracket(arr[i], EJSON.clone(parr))
        else
          sarr = parr.join(":")
          console.log("matrix: #{sarr}, path: #{arr[i]}")
          ses.path.set(sarr, arr[i])
          parr[parr.length-1]++
        i++
    else if str[n] is ")"
      bct--
    if str[n] is "/" and bct is 0
      if /[():]/.test(arr[i])
        parr[parr.length] = 0
        bracket(arr[i], EJSON.clone(parr))
      else
        sarr = parr.join(":")
        console.log("matrix: #{sarr}, path: #{arr[i]}")
        ses.path.set(sarr, arr[i])
        parr[parr.length-1]++


      i++

    else
      if arr[i]
        arr[i] = arr[i] + str[n]
      else
        arr[i] = str[n]

    if n is (str.length - 1) and arr[i]
      if /[():]/.test(arr[i])
        parr[parr.length] = 0
        bracket(arr[i], EJSON.clone(parr))
      else
        sarr = parr.join(":")
        console.log("matrix: #{sarr}, path: #{arr[i]}")
        ses.path.set(sarr, arr[i])
        parr[parr.length-1]++
    n++
  return


bracket = (str, parr) ->
  n = 0
  i = 0
  bct = 0
  bra = false
  arr = []
  while n < str.length

    if str[n] is "("
      unless bra is true
        bra = true
        if arr[i]
          if /[():/]/.test(arr[i])
            slash(arr[i], EJSON.clone(parr))
          else
            sarr = parr.join(":")
            console.log("matrix: #{sarr}, path: #{arr[i]}")
            ses.path.set(sarr, arr[i])
            parr[parr.length-1]++
          i++
      bct++

    else if str[n] is ")"
      bct--

    else if str[n] is ":" and bct is 0
      if /[():/]/.test(arr[i])
        slash(arr[i], EJSON.clone(parr))
      else
        sarr = parr.join(":")
        console.log("matrix: #{sarr}, path: #{arr[i]}")
        ses.path.set(sarr, arr[i])
        parr[parr.length-1]++
      i++

    else

      if arr[i]
        arr[i] = arr[i] + str[n]
      else
        arr[i] = str[n]

    if bct is 0 and bra is true
      if /[():/]/.test(arr[i])
        slash(arr[i], EJSON.clone(parr))
      else
        sarr = parr.join(":")
        console.log("matrix: #{sarr}, path: #{arr[i]}")
        ses.path.set(sarr, arr[i])
        parr[parr.length-1]++
      i++
      bra = false
    if n is (str.length - 1) and arr[i]
      if /[():/]/.test(arr[i])
        slash(arr[i], EJSON.clone(parr))
      else
        sarr = parr.join(":")
        console.log("matrix: #{sarr}, path: #{arr[i]}")
        ses.path.set(sarr, arr[i])
        parr[parr.length-1]++
    n++
  return

Deps.autorun ->
  if Session.equals("subscription", true)
    a = window.location.pathname
    a = Mu.remove_first_last_slash(a)
    a = "root/#{a}"
    slash(a)
    ses.current_path_n.set(a)
    return



UI.body.events
  'click a[href^="/"]': (e, t) ->
    e.preventDefault()
    a = e.currentTarget.pathname
    b = a.split(":")
    n = 0
    while n < b.length
      c = b[n].split("/")
      if n is 0
        c[0] = "root"
      b[n] = c
    window.history.pushState("","", a)
    ses.current_path_n.set(a)
    ses.current_path_arr.set(b)
    return
