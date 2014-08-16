ses.current_path_n = new Blaze.ReactiveVar()
ses.current_path_arr = new Blaze.ReactiveVar()
ses.path = new ReactiveDict()


Deps.autorun ->
  b = ses.current_path_arr.get()
  if b and b.length > 0
    n = 0
    while n < b.length
      unless ses.path.equals(n, b[n])
        ses.path.set(n, b[n])
      n++
  return


Deps.autorun ->
  if Session.equals("subscription", true)
    root = DATA.findOne(_s_n: "apps")
    if root
      ses.root = root
      if ses.root.app_dis
        document.title = ses.root.app_dis
      ses.root.paths = EJSON.parse(ses.root.paths)
    a = window.location.pathname
    b = a.split("/")
    b[0] = "root"
    ses.current_path_n.set(a)
    ses.current_path_arr.set(b)
    return

UI.body.events
  'click a[href^="/"]': (e, t) ->
    e.preventDefault()
    a = e.currentTarget.pathname
    b = a.split("/")
    b[0] = "root"
    window.history.pushState("","", a)
    ses.current_path_n.set(a)
    ses.current_path_arr.set(b)
    return
