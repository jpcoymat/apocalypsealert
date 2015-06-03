(function(){"use strict";if("undefined"==typeof sigma)throw"sigma is not declared";sigma.utils.pkg("sigma.plugins"),sigma.plugins.dragNodes=function(e,n){if(sigma.renderers.webgl&&n instanceof sigma.renderers.webgl)throw new Error("The sigma.plugins.dragNodes is not compatible with the WebGL renderer");var o=document.body,r=n.container,s=r.lastChild,t=n.camera,i=null,a="",d=!1;a=n instanceof sigma.renderers.webgl?n.options.prefix.substr(5):n.options.prefix;var u=function(e){d||(i=e.data.node,s.addEventListener("mousedown",m),d=!0)},g=function(){d&&(s.removeEventListener("mousedown",m),d=!1)},m=function(){var r=e.graph.nodes().length;r>1&&(s.removeEventListener("mousedown",m),o.addEventListener("mousemove",l),o.addEventListener("mouseup",f),n.unbind("outNode",g),n.settings({mouseEnabled:!1,enableHovering:!1}),e.refresh())},f=function(){s.addEventListener("mousedown",m),o.removeEventListener("mousemove",l),o.removeEventListener("mouseup",f),g(),n.bind("outNode",g),n.settings({mouseEnabled:!0,enableHovering:!0}),e.refresh()},l=function(n){for(var o=n.pageX-r.offsetLeft,s=n.pageY-r.offsetTop,d=Math.cos(t.angle),u=Math.sin(t.angle),g=e.graph.nodes(),m=[],f=0;2>f;f++){var l=g[f],v={x:l.x*d+l.y*u,y:l.y*d-l.x*u,renX:l[a+"x"],renY:l[a+"y"]};m.push(v)}o=(o-m[0].renX)/(m[1].renX-m[0].renX)*(m[1].x-m[0].x)+m[0].x,s=(s-m[0].renY)/(m[1].renY-m[0].renY)*(m[1].y-m[0].y)+m[0].y,i.x=o*d-s*u,i.y=s*d+o*u,e.refresh()};n.bind("overNode",u),n.bind("outNode",g)}}).call(window);