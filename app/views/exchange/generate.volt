{% extends "templates/base.volt" %}

{% block extra_js %}
{% endblock %}

{% block content %}

道具物品:<br/><br/>
{% for item in items %}
    {{item['name']}}&nbsp;&nbsp;x&nbsp;{{item['count']}}<br/>
{% endfor %}

<br/>
生成了{{code_num}}个兑换码:<br/>  
批次{{tag}}&nbsp;&nbsp;<a href="download?tag={{tag}}">下载</a><br/>


{% endblock %}


