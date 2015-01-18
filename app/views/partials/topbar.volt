<script language="javascript">
    function login() {
        $('#login-form').dialog('open');
    }
    function logout() {
        $.ajax({
            dataType: 'json',
            url: '/session/logout',
            type: 'post',
            data: '',
            success: function (data) {
                if (data.code === 0) {
                    location.reload();
                } else {
                    alert('退出登录失败!');
                }
            }
        });
    }
</script>
<div id="topbar" class="ui-layout-north ui-layout-pane ui-layout-pane-north">
    {% if uid is empty %}
        {{ link_to("javascript:void(0);", "登录", "onclick": "login();") }}
    {% else %}
        {{ "你好，" ~ name ~ "&nbsp;"}}
        {{ link_to("javascript:void(0);", "退出", "onclick": "logout();") }}

    {% endif %}
</div>