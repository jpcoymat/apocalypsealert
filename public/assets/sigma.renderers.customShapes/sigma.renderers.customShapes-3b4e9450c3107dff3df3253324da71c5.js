(function(e){"use strict";if("undefined"==typeof sigma)throw"sigma is not declared";if("undefined"==typeof ShapeLibrary)throw"ShapeLibrary is not declared";sigma.utils.pkg("sigma.canvas.nodes");var a=e,i={},r=function(e){a=e},o=function(e,r,o,n,t){if(a&&e.image&&e.image.url){var s=e.image.url,c=e.image.h||1,d=e.image.w||1,l=e.image.scale||1,m=e.image.clip||1,h=i[s];h||(h=document.createElement("IMG"),h.src=s,h.onload=function(){console.log("redraw on image load"),a.refresh()},i[s]=h);var f=c>d?d/c:1,g=d>c?c/d:1,u=n*l;t.save(),t.beginPath(),t.arc(r,o,n*m,0,2*Math.PI,!0),t.closePath(),t.clip(),t.drawImage(h,r+Math.sin(-0.7855)*u*f,o-Math.cos(-0.7855)*u*g,u*f*2*Math.sin(-0.7855)*-1,u*g*2*Math.cos(-0.7855)),t.restore()}},n=function(e,a,i){sigma.canvas.nodes[e]=function(e,r,n){var t=(arguments,n("prefix")||""),s=e[t+"size"],c=e.color||n("defaultNodeColor"),d=e.borderColor||c,l=e[t+"x"],m=e[t+"y"];r.save(),a&&a(e,l,m,s,c,r),i&&i(e,l,m,s,d,r),o(e,l,m,s,r),r.restore()}};ShapeLibrary.enumerate().forEach(function(e){n(e.name,e.drawShape,e.drawBorder)}),this.CustomShapes={init:r,version:"0.1"}}).call(this);