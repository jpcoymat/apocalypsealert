!function(t){t.fn.relativeDate=function(a){var e={dateGetter:function(a){return t(a).text()}},o=t.extend({},e,a),n=function(t){var a=new Date;return a.setTime(Date.parse(t)),r(a)},r=function(t){return u(new Date,t)},u=function(t,a){var e=(t-a)/1e3,o=Math.floor(e/60);return 0==o?"less than a minute ago":1==o?"a minute ago":45>o?o+" minutes ago":90>o?"about 1 hour ago":1440>o?"about "+Math.round(o/60)+" hours ago":2880>o?"1 day ago":43200>o?Math.floor(o/1440)+" days ago":86400>o?"about 1 month ago":525960>o?Math.floor(o/43200)+" months ago":1051199>o?"about 1 year ago":"over "+Math.floor(o/525960)+" years ago"};return t(this).each(function(){date_str=o.dateGetter(this),t(this).html(n(date_str))})}}(jQuery,window);