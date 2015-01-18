{% extends "templates/base.volt" %}

{% block extra_js %}

<script type='text/javascript'>

function submit_query() {
    var code = $("#exchange_code").val();
    var tag = $("#exchange_tag").val();
    if (!code && !tag) {
        alert("需要兑换码或批次输入");
        return;
    }
    var otable = document.getElementById('exchange_code_table');
    var obody = otable.tBodies[0];
    if (obody) {
        otable.removeChild(obody);
    }
    $("#exchange_code_count").html("");
    $.ajax({
        dataType: "json",
        type: "post",
        url: "/exchange/query",
        data: $.param({'code':code, 'tag':tag}),
        success: function(data) {
            var otable = document.getElementById('exchange_code_table');
            var tbody = document.createElement('tbody'); 
            otable.appendChild(tbody);
            if (data.code==200) {
                var codes = data.codes;
                var content = "";
                $("#exchange_code_count").html(data.count);
                if (data.count<100) {
                    for (var i=0;i<codes.length;i++) {
                        var newRow = tbody.insertRow(-1);
                        var info = codes[i];
                        var cell1 = newRow.insertCell(0);
                        cell1.innerHTML = info.code;
                        var cell2 = newRow.insertCell(1);
                        cell2.innerHTML = info.get_by;
                        var cell3 = newRow.insertCell(2);
                        cell3.innerHTML = info.get_at;
                        var cell4 = newRow.insertCell(3);
                        var expire_date = new Date(parseInt(info.expire)*1000);
                        cell4.innerHTML = expire_date.toString();
                    }
                }
            } else {
                alert(data.msg);
            }
        },
    });
}

function submit_delete() {
    var code = $("#exchange_code").val();
    var tag = $("#exchange_tag").val();
    if (!code && !tag) {
        alert("需要兑换码输入");
        return;
    }
    $.ajax({
        dataType: "json",
        type: "post",
        url: "/exchange/delete",
        data: $.param({'code':code, 'tag':tag}),
        success: function(data) {
            var otable = document.getElementById('exchange_code_table');
            var obody = otable.tBodies[0];
            if (obody) {
                otable.removeChild(obody);
            }
            if (data.code==200) {
                alert(data.msg);
            }
        }
    });
}
</script>

{% endblock %}

{% block content %}

{{ form('', 'method':'post', 'id':'queryform', 'name':'queryform') }}
    <table style="margin: 0 auto; width: 100%;" border="1">
        <tr>
            <td>
                <label for="title">批次</label>
            </td>
            <td>
                {{ text_field("exchange_tag", "size":10) }}
            </td>
            <td>
                <label for="title">兑换码</label>
            </td>
            <td>
                {{ text_field("exchange_code", "size":10) }}
            </td>
        </tr>
    </table>
    {{ submit_button("查询", "id": "query", "name": "query", "onclick": "submit_query();return false;") }}
    &nbsp;
    {{ submit_button("删除", "id": "delete", "name": "delete", "onclick": "submit_delete();return false;") }}

{{ endform() }}

<div id="exchange_code_info">
    <br/>
    <kbd>
        找到<span id="exchange_code_count"></span>条兑换码
    <table id="exchange_code_table">
        <thead>
            <tr>
            <th>兑换码</th> <th>使用者</th> <th>使用时间</th> <th>过期时间</th>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>
    </kbd>
</div>

{% endblock %}


