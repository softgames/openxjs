describe "OpenXJS", ->

  openXJS = null

  beforeEach ->
    openXJS = new OpenXJS {deliveryUrl: "http://87.230.102.59:82/openx/www/delivery/", parameters: {}}

  describe "displayAds", ->

    it "should execute the callback", (done) ->
      openXJS.displayAds {"banner1": 1, "banner2": 2}, {}, ->
        done()

    it "should display ads", (done) ->
      openXJS.displayAds {"banner1": 89, "banner2": 272}, {}, ->
        expect(document.getElementById("banner1").innerHTML).not.to.equal("")
        expect(document.getElementById("banner2").innerHTML).not.to.equal("")
        done()

    it "should leave the content", (done) ->
      openXJS.displayAds {"banner1": 89, "banner2": 2}, {}, ->
        expect(document.getElementById("content").innerHTML).to.equal("CONTENT")
        done()

  describe "receiveAdCodes", ->

    it "should return all setted codes", (done) ->
      openXJS.receiveAdCodes {"banner1": 89, "banner2": 999999}, {}, (codes) ->
        expect(codes['banner1']).to.not.equal(undefined)
        expect(codes['banner2']).to.equal(undefined)
        done()

    it "should generate a correct query string", (done) ->
      sinon.spy openXJS, "_queryString"
      sinon.stub openXJS, "_documentCharset", -> "UTF-8"
      sinon.stub openXJS, "_randomNumber", -> "5"
      sinon.stub openXJS, "_location", -> "http://example.domain.com/"
      sinon.stub openXJS, "_referrer", -> "http://referrer.domain.com/"

      params = 
        zones: "|banner1=89|banner2=2|"
        nz: 1
        blockcampaign: 1
        charset: "UTF-8"
        cb: "5"
        r: "5"
        loc: "http://example.domain.com/"
        referer: "http://referrer.domain.com/"
        first: "param"
        second: "param"

      openXJS.displayAds {"banner1": 89, "banner2": 2}, {first: "param", second: "param"}, ->
        expect(openXJS._queryString.withArgs(params).called).to.be.true;
        done()

    it "should load the ads from OpenX with correct parameters", (done) ->
      sinon.spy openXJS, "_loadScript"
      sinon.stub openXJS, "_queryString", -> "queryString"

      openXJS.displayAds {"banner1": 89, "banner2": 2}, {first: "param", second: "param"}, ->
        expect(openXJS._loadScript.withArgs("http://87.230.102.59:82/openx/www/delivery/spc.php?queryString").called).to.be.true
        done()

  describe "_openxParameters", ->
    it "should include passed params", ->
      openXJS.defaultParameters = {"a" : 1}
      mergableParams = {"b" : 2}
      expect(openXJS._openxParameters({}, mergableParams)).have.keys('a', 'b')
    
    it "should overwrite default params", ->
      openXJS.defaultParameters = {"a" : 1}
      mergableParams = {"a" : 2}
      expect(openXJS._openxParameters({}, mergableParams)["a"]).to.equal(2)

  describe "_randomNumber", ->
    it "should never be the same", ->
      expect(openXJS._randomNumber()).not.to.equal(openXJS._randomNumber())

  describe "_location", ->
    it "should equal window.location", ->
      expect(openXJS._location()).to.equal(window.location)

  describe "_referrer", ->
    it "should equal document.referrer", ->
      expect(openXJS._referrer()).to.equal(document.referrer)

  describe "_documentCharset", ->
    it "should equal document.charset", ->
      if document.characterSet
        expect(openXJS._documentCharset()).to.equal(document.characterSet)
      else
        expect(openXJS._documentCharset()).to.equal(document.charset)

  describe "_queryString", ->
    it "should return a proper query string", ->
      expect(openXJS._queryString({first: "par am", second: "param"})).to.equal("first=par%20am&second=param")

  describe "_emptyResponse", ->
    it "should return true if not defined", ->
      expect(openXJS._emptyResponse()).to.be.true
    it "should return true if empty string", ->
      expect(openXJS._emptyResponse("")).to.be.true
    it "should return true if OpenX unknown zone response", ->
      expect(openXJS._emptyResponse("<a href=\'F\' target=\'_blank\'><img src=\'F\' border=\'0\' alt=\'\'></a>\n")).to.be.true
    it "should return false if valid response", ->
      expect(openXJS._emptyResponse("ad-code")).to.be.false

  describe "_mergeObjects", ->
    initialObject = null
    beforeEach ->
      initialObject = {a: 1, b: 2}

    it "should merge 2 objects", ->
      mergableObject = {c: 3, d: 4}
      expectedResult = {a: 1, b: 2, c: 3, d: 4}
      expect(openXJS._mergeObjects(initialObject, mergableObject)).to.eql(expectedResult)
    it "should overwrite if conflict", ->
      mergableObject = {b: 2, c: 3}
      expectedResult = {a: 1, b: 2, c: 3}
      expect(openXJS._mergeObjects(initialObject, mergableObject)).to.eql(expectedResult)      