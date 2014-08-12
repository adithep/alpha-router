
ses.current_path_n = new Blaze.ReactiveVar()
ses.path = new ReactiveDict()
Deps.autorun ->
  if ses.subscription.get() is true
    root = DATA.findOne(_s_n: "paths", path_n: "blank")
    if root and root.path_dis
      document.title = root.path_dis
    a = window.location.pathname
    b = a.split("/")
    b[0] = "blank"
    ses.current_path_n.set(a)
    n = 0
    while n < b.length
      unless ses.path.equals(n, b[n])
        ses.path.set(n, b[n])
      n++
    return

UI.body.events
  'click a[href^="/"]': (e, t) ->
    e.preventDefault()
    a = e.currentTarget.pathname
    b = a.split("/")
    b[0] = "blank"
    window.history.pushState("","", a)
    ses.current_path_n.set(a)
    ses.current_path.set(b)
    return
