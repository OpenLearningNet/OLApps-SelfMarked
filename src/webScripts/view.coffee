include "mustache.js"
include "util.js"

template = include "viewTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"

checkPermission 'read', accessDeniedTemplate, ->
	view = {}
	
	view.isCompleted = false

	if request.method is 'POST'
		view.isCompleted = true
		view.updated = true
		marksObject = {}
		marksObject[request.user] = {
			completed: view.isCompleted
		}
		
		try
			OpenLearning.activity.submit request.user
			OpenLearning.activity.setMarks marksObject
		catch err
			view.error = 'Something went wrong: Unable to save data'
	else
		try
			marks = (OpenLearning.activity.getMarks [request.user])
			view.isCompleted = marks[request.user].completed
		catch err
			view.error = 'Something went wrong: Unable to load data'

	# get activity page data
	try
		page = OpenLearning.page.getData( request.user )
		activityData = page.data
		view.url = page.url
	catch err
		view.error = 'Something went wrong: Unable to load data'

	if activityData
		view.buttonText = activityData.buttonText
		view.buttonTextDone = activityData.buttonTextDone
	else
		view.buttonText = "I've Done This"
		view.buttonTextDone = "Marked as Done"

	render template, view

