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
    ses.path.set(n, false)
  return

Deps.autorun ->
  if Session.equals("subscription", true)
    root = DATA.findOne(_s_n: "apps")
    if root and root.app_dis
      document.title = root.app_dis
    return


Deps.autorun ->
  if Session.equals("subscription", true)
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
