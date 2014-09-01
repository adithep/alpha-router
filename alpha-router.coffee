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


colon = (str) ->
  b = str.split(":")
  n = 0
  while n < b.length
    if b[n].indexOf("/") isnt -1
      b[n] = slash(b[n])
    n++
  return b

slash = (str) ->
  b = str.split("/")
  n = 0
  while n < b.length
    if b[n].indexOf(":") isnt -1
      b[n] = colon(b[n])
    n++
  return b


Deps.autorun ->
  if Session.equals("subscription", true)
    a = window.location.pathname
    a = Mu.remove_first_last_slash(a)
    n = 0
    i = 0
    bct = 0
    arr = []
    while n < a.length
      if a[n] is "("
        bct++
      else if a[n] is ")"
        bct--
      if a[n] is "/" and bct is 0
        i++
      else
        if arr[i]
          arr[i] = arr[i] + a[n]
        else
          arr[i] = a[n]
      n++
    console.log(arr)
    #ses.current_path_n.set(a)
    #ses.current_path_arr.set(b)
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
