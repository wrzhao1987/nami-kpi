{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/dt/jquery.dataTables.min.js") }}
    {{ javascript_include("/js/dt/dataTables.jqueryui.js") }}
    <script language="JavaScript">
        $(function() {
            $('#code-form').dataTable();
            $('.edit').button();
        });
    </script>
{% endblock %}
{% block extra_css %}
    {{ stylesheet_link("/css/dt/dataTables.jqueryui.css") }}
{% endblock %}
{% block content %}
    {{ link_to('/exchange/addType', "点此添加模板", "class":"edit") }}
    {% if e_types is defined %}
        <div class="ui-layout-pane" style="margin-top:100px;">
            <table id="code-form" class="display" style="text-align: center;">
                <thead>
                <tr>
                    <th>编号</th>
                    <th>名称</th>
                    <th>内容</th>
                    <th>开始时间</th>
                    <th>结束时间</th>
                    <th>渠道编号</th>
                    <th>重复使用</th>
                    <th>操作</th>
                </tr>
                </thead>
                <tbody>
                {% for type in e_types %}
                    <tr>
                        <td><label>{{ type['id'] }}</label></td>
                        <td><label>{{ type['name'] }}</label></td>
                        <td>
                            <ul style="text-align: left;">
                            {% for val in type['items'] %}
                            <li>
                                {{ item_names[val['item_id']] }}
                                {% if sub_names[val['item_id']][val['sub_id']] is defined %}
                                    - {{ sub_names[val['item_id']][val['sub_id']] }}
                                {% endif %}
                                X {{ val['count'] }}
                            </li>
                            {% endfor %}
                            </ul>
                        </td>
                        <td><label>{{ type['start_date'] }}</label></td>
                        <td><label>{{ type['end_date'] }}</label></td>
                        <td><label>{{ channel_conv[type['channel_id']] }}</label></td>
                        <td><label>{% if type['reuse'] == 1 %}可重复多次使用{% elseif type['reuse'] == 2 %}使用后失效{% endif %}</label></td>
                        <td>
                            {{ link_to('/exchange/editType?type_id=' ~ type['id'], "编辑", "class":"edit") }}
                            {{ link_to('/announce/delType?type_id=' ~ type['id'], "删除", "class":"edit") }}
                        </td>
                    </tr>
                {% endfor %}
                </tbody>
            </table>
        </div>
    {% endif %}
{% endblock %}