{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/dt/jquery.dataTables.min.js") }}
    {{ javascript_include("/js/dt/dataTables.jqueryui.js") }}
    <script language="JavaScript">
        $(function () {
            $("#start_date").datepicker({dateFormat: "yymmdd"});
            $("#end_date").datepicker({dateFormat: "yymmdd"});
            $('#admin-form').dataTable();
            $('#budan_alert').dialog({
                autoOpen: false,
                buttons: {
                    "知道了": function() {
                        $(this).dialog("close");
                    }
                }
            });
        });
        function budan_confirm(order_id, srv_id)
        {
            $("#budan_order_id").val(order_id);
            $("#budan_srv_id").val(srv_id);
            $.ajax({
                dataType: "json",
                type: "post",
                url: "/order/budan",
                data: 'order_id=' + order_id + '&srv_id=' + srv_id,
                success: function(data) {
                    if (data.code !== 0) {
                        alert(data.msg);
                        return false;
                    } else {
                        $("#budan_order_id").removeAttr('value');
                        $("#budan_srv_id").removeAttr('value');
                        $("#budan_alert").dialog("open");
                        return true;
                    }
                }
            });
        }
    </script>
{% endblock %}
{% block extra_css %}
    {{ stylesheet_link("/css/dt/dataTables.jqueryui.css") }}
    <style type="text/css">
        .t_label {
            background-color: deepskyblue;
        }
    </style>
{% endblock %}
{% block content %}
    {% if notice['code'] != 403 and uid > 0 %}
        <div class="ui-layout-pane" style="margin-top:100px;">
            {{ form('/order/query', 'method':'post', 'id':'myform', 'name':'myform') }}
            <fieldset>
                <table style="margin: 0 auto; width: 100%;" border="1">
                    <tr>
                        <td colspan="2">
                            <label>服务器:</label>
                            {{ select_static("srv_id", srv_list) }}
                        </td>
                        <td colspan="2">
                            <label>平台:</label>
                            {{ select_static("src_id", src_list) }}
                        </td>
                        <td colspan="2">
                            <label>UID:</label>
                            {{ text_field("user_id", "size": 50) }}
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <label>订单号:</label>
                            {{ text_field("order_id", "size": 50) }}
                        </td>

                        <td colspan="3">
                            <label>第三方订单号:</label>
                            {{ text_field("thr_order", "size": 50) }}
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <label>开始日期:</label>
                            {{ text_field("start_date", "size": 50) }}
                        </td>

                        <td colspan="3">
                            <label>结束日期:</label>
                            {{ text_field("end_date", "size": 50) }}
                        </td>
                    </tr>
                    <tr>
                        <td colspan="6" style="text-align: center;">
                            {{ submit_button("查询", "id": "sub_btn", "name": "sub_btn") }}
                        </td>
                    </tr>
                </table>
                {{ hidden_field(security.getTokenKey(), "value": security.getToken()) }}
            </fieldset>
            {{ end_form() }}
        </div>
    {% endif %}
    {% if orders is defined %}
        <div class="ui-layout-pane" style="margin-top:100px;">
        <table id="admin-form" class="display" border="1" style="text-align: center;">
            <thead>
            <tr>
                <th>用户ID</th>
                <th>用户昵称</th>
                <th>平台</th>
                <th>订单号</th>
                <th>购买商品</th>
                <th>商品价格</th>
                <th>订单状态</th>
                <th>是否测试订单</th>
                <th>第三方订单号</th>
                <th>创建时间</th>
                <th>上次更新时间</th>
                <th>操作</th>
            </tr>
            </thead>
            <tbody>
            {% for order in orders %}
                <tr>
                    <td>{{ order['user_id'] }}</td>
                    <td>{{ order['user_name'] }}</td>
                    <td>{{ order['src_name'] }}</td>
                    <td>{{ order['order_id'] }}</td>
                    <td>{{ order['package_id'] }}</td>
                    <td>{{ order['amount'] }}</td>
                    <td>{{ order['status_str'] }}</td>
                    <td>{{ order['debug'] }}</td>
                    <td>{{ order['thr_order'] }}</td>
                    <td>{{ order['create_time'] }}</td>
                    <td>{{ order['update_time'] }}</td>
                    <td>
                        {% if order['status'] == 2 %}
                            <button class="edit" onclick="budan_confirm('{{ order['order_id'] }}', '{{ srv_id }}');">补单</button>
                        {% endif %}
                    </td>
                </tr>
            {% endfor %}
            </tbody>
        </table>
    </div>
    {% endif %}
    <div id="budan_alert" title="补单请求发送">
        <p>补单请求已发送，预计一分钟后补单完成.</p>
        <input type="hidden" id="budan_order_id" name="budan_order_id" />
        <input type="hidden" id="budan_srv_id" name="budan_srv_id" />
    </div>
{% endblock %}
