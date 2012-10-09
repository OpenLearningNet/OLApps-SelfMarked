include "mustache.js"
include "util.js"

template = include "adminTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"

fields = ['buttonText', 'buttonTextDone']
booleanFields = []

setDefaults = (view) ->
	if not view.buttonText?
		view.buttonText = "I've Done This"

	if not view.buttonTextDone?
		view.buttonTextDone = "Marked as Done"

# POST and GET controllers
post = ->
	# grab data from POST
	view = {}

	# this app always has something embedded in the activity page
	view.isEmbedded = true

	for field in fields
		view[field] = request.data[field]

	for field in booleanFields
		if request.data[field] is 'yes'
			view[field] = true
		else
			view[field] = false

	# set activity page data
	try
		view.url = (OpenLearning.page.setData view, request.user).url
	catch err
		view.error = 'Something went wrong: Unable to save data'

	view.message = 'Saved'
	return view

get = ->
	view = {}

	# get activity page data
	try
		page = OpenLearning.page.getData( request.user )
		data = page.data
		view.url = page.url
	catch err
		view.error = 'Something went wrong: Unable to load data'
	
	if not view.error?
		# build view from page data
		for field in fields
			view[field] = data[field]

	return view


checkPermission 'write', accessDeniedTemplate, ->
	view = {}
	if request.method is 'POST'
		view = post()
	else
		view = get()

	setDefaults view

	render template, view

