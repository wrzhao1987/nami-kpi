{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/timepicker.js") }}
    <script type='text/javascript'>
        $(function() {
            var curr_count = 0;
            $("#generate").button();
            $("fieldset input").addClass('ui-widget-content ui-corner-all');
            $("#add-item").button().click(function (event) {
                var item_list = '<select onchange="getSubList(' + curr_count + ');" class="items" ' +
                        'id="item_list' + curr_count + '" name="items[' + curr_count + '][item_id]">';
                item_list = item_list + '<option value="0">请选择类型</option>';
                {% for item_id, item_name in item_list %}
                item_list = item_list + '<option value="' + {{ item_id }} + '">' + '{{ item_name }}' + '</option>'
                {% endfor %}
                item_list = item_list + '</select>';
                var items = '<p>' + item_list
                        + '<input id="item_count'+ curr_count +'" name="items[' + curr_count
                        + '][count]" type="text" placeholder="请输入数量" />' + '</p>';
                $(this).before(items);
                var del_btn = '<button id="delBtn' + curr_count +'"onclick="return delItem(' + curr_count + ');">删除</button>';
                $("#item_count" + curr_count).after(del_btn);
                curr_count++;
            });
            $("#start_date").datepicker({ dateFormat: "yy-mm-dd" });
            $("#end_date").datepicker({ dateFormat: "yy-mm-dd" });
        });

        function getSubList(list_no)
        {
            var item_list = $('#item_list' + list_no);
            var sub_list  = '<select id="sub_list' + list_no +  '" name="items[' + list_no + '][sub_id]">';
            sub_list  = sub_list + '<option value="0">请选择子类型</option>';

            $("#sub_list" + list_no).remove();
            $.getJSON('/ajax/itemsub', {item_id: item_list.val()}, function (json) {
                for (var sub_id in json) {
                    sub_list = sub_list + '<option value="' + sub_id + '">' + json[sub_id] + '</option>';
                }
                sub_list = sub_list + '</select>';
                item_list.after(sub_list);
            });
        }

        function delItem(list_no)
        {
            $("#item_list" + list_no).remove();
            $("#sub_list" + list_no).remove();
            $("#item_count" + list_no).remove();
            $("#delBtn" + list_no).remove();
            return false;
        }

        function submit_check() {
            var start_date = $("#start_date").val();
            if ( !start_date ) {
                alert("请选择开始时间");
                return false;
            }
            var end_date = $("#end_date").val();
            if ( !end_date ) {
                alert("请选择结束时间");
                return false;
            }
            var items = [];
            var item_num = $(".items").length;
            if (item_num <=0) {
                alert("没有指定物品");
                return false;
            }
            for (var i=1;i<=item_num;i++) {
                var item_id = $("#item_list"+i).val();
                var sub_id = 0;
                var e_sub_id = $("select[name='items["+i+"][sub_id]']");
                if (e_sub_id.length>0) {
                    sub_id = e_sub_id[0].value;
                } else {
                    sub_id = 1;
                }
                var count = $("input[name='items["+i+"][count]']")[0].value;
                if (item_id<=0 || sub_id<=0 || count<=0) {
                    alert('物品信息不全');
                    return false;
                }
                if (item_id>0 && sub_id>0 && count>0) {
                    items.push({'item_id':item_id, 'sub_id': sub_id, 'count': count});
                }
            }
            return true;
        }
    </script>
{% endblock %}

{% block extra_css %}
    {{ stylesheet_link("/css/timepicker.css") }}
{% endblock %}
{% block content %}

    <fieldset>
    {% if notice['code'] != 403 %}
        {{ form('/exchange/addType', 'method':'post', 'id':'exchangeform', 'name':'exchangeform') }}
        <table style="margin: 0 auto; width: 100%;" border="1">
            <tr>
                <td>
                    <label for="title">礼包名称:</label>
                    {{ text_field("name", "size":20) }}
                </td>
                <td>
                    <label>适用渠道:</label>
                    <select id="channel_id" name="channel_id">
                        <option value="1">安卓区</option>
                        <option value="2">苹果区</option>
                        <option value="3">越狱区</option>
                        <option value="4">测试区</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="title">开始日期:</label>
                    {{ text_field("start_date", "readonly": "readonly") }}
                </td>
                <td>
                    <label>结束日期:</label>
                    {{ text_field("end_date", "readonly": "readonly") }}
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <label for="title">使用规则:</label>
                    <select id="reuse" name="reuse">
                        <option value="1">可重复多次使用</option>
                        <option value="2">使用后失效</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <a href="javascript:void(0);" id="add-item">添加一个物品</a>
                </td>
            </tr>
        </table>
        {{ submit_button("添加", "id": "generate", "name": "generate", "onclick": "return submit_check();") }}
        {{ endform() }}
        </fieldset>
    {% endif %}
{% endblock %}
