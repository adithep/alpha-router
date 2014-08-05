space_build_n = (path, parent, depth) ->
  if path and parent
    path_id = LDATA.insert(
      path: path.path_n
      _mid: parent
      depth: depth
      _s_n: "path"
    )
    DATA.find(_s_n: "_spa", _spa: {$in: path.path_spa_arr}).forEach (doc) ->
      if LDATA.find(_spa: doc._spa, _pid: path_id, _s_n: "_spa").count() < 1
        ind = path.path_spa_arr.indexOf(doc._spa)
        spa = space_bud(
          doc
          path_id
          depth
          ind
        )
        Session.set("#{path_id}#{doc._spa_tem}", spa)
      else
        dgr = LDATA.findOne(_spa: doc._spa, _pid: path_id, _s_n: "_spa")
        unless Session.equals("#{path_id}#{doc._spa_tem}", dgr._id)
          Session.set("#{path_id}#{doc._spa_tem}", dgr._id)
    return path_id
  return false

space_bud = (_spa, parent, depth, spa_sort) ->
  spa = LDATA.insert(
    _spa: _spa._spa
    _pid: parent
    depth: depth
    sort: spa_sort
    _spa_tem: _spa._spa_tem
    _s_n: "_spa"
  )
  k = 0
  if _spa._spa_gr_arr
    arr = _spa._spa_gr_arr
    while k < arr.length
      gr = LDATA.insert(
        _gr: arr[k]
        _sid: spa
        sort: k
        depth: depth
        _pid: parent
        _s_n: "_gr"
      )
      obj = {}
      pa = "_tri_grs.#{arr[k]}"
      obj[pa] = {$exists: true}
      obj._s_n = "_tri"
      DATA.find(obj).forEach (doc) ->
        ld = {}
        ld._did = doc._id
        ld.depth = depth
        if doc._tri_grs[arr[k]].sort?
          ld.sort = doc._tri_grs[arr[k]].sort
        ld._gid = gr
        ld._sid = spa
        ld._pid = parent
        ld._s_n = "doc"
        console.log doc
        id = LDATA.insert(ld)
        if doc._tri_ty is "input" and doc.key_ty and doc.key_ty is "r_st"
          dgr = LDATA.findOne(_gr: "_sel_opt", _sid: id)
          unless dgr
            cdr = space_bud_d(
              doc.key_s
              doc.key_key
              "_sel_opt"
              id
              depth
              spa
              parent
            )
            Session.set("#{id}_sel_opt", cdr)
          else
            unless Session.equals("#{id}_sel_opt", dgr._id)
              Session.set("#{id}_sel_opt", dgr._id)
      k++
  return spa

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

ses.current_path = new Blaze.reactiveVar()

set_path_n = (path) ->
  b = path.split('/')
  b[0] = "blank"
  n = 0
  par = "top"
  cur = "current_session"
  while n < b.length
    gma = DATA.findOne(_s_n: "paths", path_n: b[n])
    if gma
      dgr = LDATA.findOne(path: gma.path_n, _mid: par, _s_n: "path")
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
  if Session.equals("subscription", true)
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
