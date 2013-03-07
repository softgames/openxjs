###
OpenXJS
Copyright(c) 2013 Softgames GmbH <scotty@softgames.de>
###

class window.OpenXJS

  spcScript : "spc.php"

  constructor : (options) ->
    @deliveryUrl = options.deliveryUrl
    @defaultParameters = options.parameters
    
  # Display ads from OpenX
  displayAds : (zonesMapping, parameters, callback) ->
    @receiveAdCodes zonesMapping, parameters, (codes) =>
      for target, code of codes
        @_displayAd target, code
      callback?()

  # Request ad codes from OpenX
  receiveAdCodes : (zonesMapping, parameters, callback) ->
    openXParameters = @_openxParameters zonesMapping, parameters
    scriptUrl = @deliveryUrl + @spcScript + "?" + @_queryString openXParameters
    @_loadScript scriptUrl, =>
      @_parseResponse zonesMapping, callback

  ##
  # PRIVATE
  ##

  # Handle the response from OpenX
  _parseResponse : (zonesMapping, callback) ->
    codes = {}
    if typeof window.OA_output != "object"
      window.OA_output = null
      callback? codes
      return
    for target, zone of zonesMapping
      continue if @_emptyResponse window.OA_output[target]
      codes[target] = window.OA_output[target]
    window.OA_output = null
    callback? codes

  # Print a single ad
  _displayAd : (target, code) ->
    targetElement = document.getElementById(target)
    return if targetElement == null
    document.getElementById(target).innerHTML = code
  
  # Create OpenX parameters
  _openxParameters : (zonesMapping, parameters) ->
    mergedParameters = @_mergeObjects(@defaultParameters, parameters)
    mappingString = "|"
    for target, zone of zonesMapping
      mappingString += "#{target}=#{zone}|"

    openXParameters =
      zones: mappingString
      nz: 1
      blockcampaign: 1
      charset: @_documentCharset()
      cb: @_randomNumber()
      r: @_randomNumber()
      loc: @_location()
      referer: @_referrer()

    for key, value of mergedParameters
      openXParameters[key] = value
    openXParameters

  # Load a javascript file
  _loadScript : (url, callback) ->
    s = document.createElement('script')
    s.async = "async"
      
    # Script loaded event
    called = false
    s.onload = s.onreadystatechange = =>
      if (s.readyState && !(/complete|loaded/.test(s.readyState))) || called
        return
      called = true
      s.onload = s.onreadystatechange = null
      callback?()
    s.src = url
    @_appendToHead s

  _randomNumber : ->
    Math.floor (Math.random() * 99999999999)

  _location : ->
    window.location

  _referrer : ->
    document.referrer

  _documentCharset : ->
    if document.charset then document.charset else (if document.characterSet then document.characterSet else "")

  _emptyResponse : (response) ->
    (
      typeof response != "string" || 
      response == "" ||
      response == "<a href=\'F\' target=\'_blank\'><img src=\'F\' border=\'0\' alt=\'\'></a>\n"
    )

  # Generates a query string
  _queryString : (parameters) ->
    elements = []
    for name, value of parameters
      elements.push "#{name}=#{encodeURIComponent(value)}" if value?
    elements.join '&'

  # Insert into the head of the page
  _appendToHead : (element) ->
    head = document.head || document.getElementsByTagName( "head" )[0] || document.documentElement
    head.insertBefore element, head.firstChild

  # Merges 2 js objects
  _mergeObjects : (obj1, obj2) ->
    obj3 = {}
    for attrname of obj1
      obj3[attrname] = obj1[attrname]
    for attrname of obj2
      obj3[attrname] = obj2[attrname]
    obj3