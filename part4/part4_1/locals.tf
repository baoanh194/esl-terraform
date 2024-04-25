# set the content type in S3 based on each file’s extension
locals { 
	content_types = { 
		".html" : "text/html", 
		".css" : "text/css"
		# ".js" : "text/javascript" 
	} 
}
