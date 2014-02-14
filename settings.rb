CONSUMER_KEY = 'xxxxxxxxxx'
CONSUMER_SECRET = 'xxxxxxxxxx'

SESSION_SECRET = "xxxxxxxxxx"
SESSION_EXPIRE_AFTER = 60 * 60 * 24 * 30  # 30 days

BOOKMARKLET = 'javascript:(function(e){window.open("http://miteru.odiak.net/post?url="+e(location.href)+"&title="+e(document.title),null,"width=480,height=240");})(encodeURIComponent);'
