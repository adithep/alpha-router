ses.current_path_n = new Blaze.ReactiveVar()
ses.current_path_arr = new Blaze.ReactiveVar()
ses.current_path_h = new Blaze.ReactiveVar("Home")
ses.path = new ReactiveDict()
ses.state_glyph = {}
ses.tem = {}


Tracker.autorun ->
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

Tracker.autorun ->
  if Session.equals("subscription", true)
    root = DATA.findOne(_s_n: "apps")
    if root and root.app_dis
      ses.app = new Blaze.ReactiveVar(root)
      document.title = root.app_dis
    return

Tracker.autorun ->
  DATA.find(_s_n: "form_state_glyph").observe

    added: (doc) ->

      ses.state_glyph[doc.form_state_set_n] = new Blaze.ReactiveVar(doc)

    changed: (ndoc) ->
      ses.state_glyph[doc.form_state_set_n].set(ndoc)

    removed: (doc) ->

      delete ses.state_glyph[doc.form_state_set_n]

Tracker.autorun ->
  DATA.find(_s_n: "templates").observe

    added: (doc) ->

      ses.tem[doc.tem_ty_n] = new Blaze.ReactiveVar(doc)

    changed: (ndoc) ->
      ses.tem[doc.tem_ty_n].set(ndoc)

    removed: (doc) ->

      delete ses.tem[doc.tem_ty_n]


matrix = (str, pparr) ->
  n = 0
  bct = 0
  bru = false
  sla = false
  parr = pparr or [0]
  nstr = ""
  while n < str.length
    nstr = nstr + str[n]
    if str[n] is "("
      ostr = nstr.replace(/\($/g, '')
      if bct is 0
        ostr = ostr.replace(/^\(|\)$/g, '')
      if ostr.length >=1 and ostr.indexOf("(") is -1
        ostr = ostr.replace(/^\(|\)$/g, '')
        sarr = parr.join("")
        ses.path.set(sarr, ostr)
        parr[parr.length-1]++
        nstr = ""
      bct++
    else if str[n] is ")"
      bct--
    if bct >= 2 or (bct is 1 and (str[n] is ":" or str[n] is "/" ))
      bru = true
    if str[n] is "/"
      sla = true
    else
      sla = false


    if (str[n] is ":" and bct is 0)

      nstr = nstr.replace(/^\/|\/$/g, '')
      nstr = nstr.replace(/^\(|\)$|:$|^:/g, '')
      if bru is true
        carr = _.clone(parr)
        matrix(nstr, carr)

        parr[parr.length] = 0
        parr[parr.length-1]++
      else
        sarr = parr.join("")
        ses.path.set(sarr, nstr)
        parr[parr.length-1]++
      bru = false
      nstr = ""

    if (str[n] is "/" and bct is 0) or (n is str.length - 1)

      nstr = nstr.replace(/^\/|\/$/g, '')
      nstr = nstr.replace(/^\(|\)$|:$|^:/g, '')
      if bru is true
        carr = _.clone(parr)
        matrix(nstr, carr)

        parr[parr.length] = 0
        parr[parr.length-1]++
      else
        sarr = parr.join("")
        ses.path.set(sarr, nstr)
        parr[parr.length] = 0
      bru = false
      nstr = ""
    if n is str.length - 1
      sarr = parr.join("")
      ses.path.set(sarr, false)


    n++

Tracker.autorun ->
  if Session.equals("subscription", true)
    a = window.location.pathname
    b = Mu.remove_first_last_slash(a)
    b = "root/#{b}"
    matrix(b)
    ses.current_path_n.set(a)
    return

hide_drop = (dvis) ->
  if dvis.dvis
    dvis.dvis.set('hide')
    if dvis.ctl and dvis.ctl.ptl
      hide_drop(dvis.ctl.ptl)


UI.body.events
  'click a[href^="/"]': (e, t) ->
    e.preventDefault()
    if @dtl.doc.path_dis
      ses.current_path_h.set(@dtl.doc.path_dis)
    else
      ses.current_path_h.set("Home")
    if @ctl.ptl
      hide_drop(@ctl.ptl)
    a = e.currentTarget.pathname
    b = Mu.remove_first_last_slash(a)
    b = "root/#{b}"
    matrix(b)
    window.history.pushState("","", a)
    ses.current_path_n.set(a)
    return
