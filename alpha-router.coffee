space_build_n = (path, parent, depth) ->
  if path and parent
    path_id = LDATA.insert(
      path_n: path.path_n
      _mid: parent
      depth: depth
      _s_n: "paths"
    )
    if path.path_ctl_arr and Array.isArray(path.path_ctl_arr)
      DATA.find(_s_n: "_ctl", _ctl_n: {$in: path.path_ctl_arr}).forEach (doc) ->
        if LDATA.find(_ctl_n: doc._ctl_n, _pid: path_id, _s_n: "_ctl").count() < 1

          ind = path.path_ctl_arr.indexOf(doc._ctl_n)
          _ctl = space_bud(
            doc
            path_id
            depth
            ind
          )
          Session.set("#{path_id}#{doc._ctl_n}", _ctl)
        else
          dgr = LDATA.findOne(_ctl_n: doc._ctl_n, _pid: path_id, _s_n: "_ctl")
          unless Session.equals("#{path_id}#{doc._ctl_n}", dgr._id)
            Session.set("#{path_id}#{doc._ctl_n}", dgr._id)
    return path_id
  return false

space_bud = (_ctl, parent, depth, ctl_sort) ->
  ctl = LDATA.insert(
    _ctl_n: _ctl._ctl_n
    _pid: parent
    depth: depth
    sort: ctl_sort
    _ctl_id: _ctl._id
    _s_n: "_ctl"
  )
  depth++
  if _ctl.data
    obj = EJSON.parse(_ctl.data)
    n = 0
    DATA.find(obj).forEach (doc) ->
      if _ctl.data.data_sort_key and _ctl.data.data_sort_arr
        sort = _ctl.data.data_sort_arr.indexOf(doc[_ctl.data.data_sort_key])
      else
        sort = n++
      switch doc._s_n
        when "_ctl"
          space_bud(doc, ctl, depth, sort)
        else
          data = LDATA.insert(
            _cid: ctl
            depth: depth
            sort: sort
            _did: doc._id
            _s_n: "data"
          )
  if _ctl.data_func
    data_func = LDATA.insert(
      _cid: ctl
      depth: depth
      _fid: _ctl.data_func
      _s_n: "data"
    )

  return ctl

@space_bud_d = (_s_n, key, name, parent, depth, spa, pid) ->
  gr = LDATA.insert(
    _gr: name
    _sid: parent
    depth: depth
    _spa: spa
    _pid: pid
    _s_n: "_gr"
  )
  one = true
  DATA.find({_s_n: _s_n}, {limit: 5}).forEach (doc) ->
    ld = {}
    ld._did = doc._id
    ld._gid = gr
    ld._spa = spa
    ld._pid = pid
    ld.depth = depth
    ld._s_n = "doc"
    console.log doc
    id = LDATA.insert(ld)
    if one is true and key
      console.log doc[key]
      unless Session.equals("#{parent}_v", doc[key])
        Session.set("#{parent}_v", doc[key])
      one = false
  return gr

t_build_s = (_s_n, parent, gid, key) ->
  if _s_n and parent
    group = LDATA.insert(_spa: gid, _mid: parent)
    one = true
    DATA.find(_s_n: _s_n).forEach (doc) ->
      ld = {}
      ld._did = doc._id
      ld._gid = group
      id = LDATA.insert(ld)
      if one is true and key
        unless Session.equals("#{parent}_v", doc[key])
          Session.set("#{parent}_v", doc[key])
        one = false
      if doc.key_ty and doc.key_ty is "r_st"
        t_build_s(doc.key_s, id, parent, doc.key_key)
    return group
  return false

ses.current_path = new Blaze.ReactiveVar()
ses.current_session = new Blaze.ReactiveVar()

set_path_n = (path) ->
  b = path.split('/')
  b[0] = "blank"
  n = 0
  par = "top"
  cur = "current_session"
  while n < b.length
    gma = DATA.findOne(_s_n: "paths", path_n: b[n])
    if gma
      dgr = LDATA.findOne(path_n: gma.path_n, _mid: par, _s_n: "paths")
      if dgr
        unless Session.equals(cur, dgr._id)
          Session.set(cur, dgr._id)
        cur = "#{dgr._id}_path"
        par = dgr._id
      else
        gr = space_build_n(gma, par, n)
        par = gr
        Session.set(cur, gr)
        cur = "#{gr}_path"
    n++
  Session.set(cur, false)
  return

Deps.autorun ->
  if ses.subscription.get() is true
    root = DATA.findOne(_s_n: "paths", path_n: "blank")
    if root and root.path_dis
      document.title = root.path_dis
    a = window.location.pathname
    set_path_n(a)
    Session.set("current_path", a)

UI.body.events
  'click a[href^="/"]': (e, t) ->
    e.preventDefault()
    a = e.currentTarget.pathname
    set_path_n(a)
    window.history.pushState("","", a)
    Session.set("current_path", a)
    return
