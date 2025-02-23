class DashboardPOM {
    logo = "#logo"

    userInfos = {
        container: "#userInfos",
        titleSelector: "#userInfosTitle",
        titleTxt: "My Informations",
        editBtn: "#userInfosEditBtn",
        panel: {
            container: "#userInfosContainer",
            username: {
                container: "#usernameContainer",
                labelSelector: "#usernameLabel",
                labelTxt: "Username",
                value: "#usernameValue",
            },
            email: {
                container: "#emailContainer",
                labelSelector: "#emailLabel",
                labelTxt: "Email",
                value: "#emailValue",
            },
            lastLogin: {
                container: "#lastLoginContainer",
                labelSelector: "#lastLoginLabel",
                labelTxt: "Last login",
                value: "#lastLoginValue",
            },
        }
    }

    clock = {
        container: "#clockInOut",
        titleSelector: "#clockInOutTitle",
        titleTxt: "Time clock",
        panel: {
            container: "#clockInOutContainer",
            status: {
                container: "#clockStatus",
                value: "#clockStatusValue",
            },
            lastClockIn: "#lastClockIn",
            timeElapsed: "#timeElapsed",
            button: "#clockBtn",
        }
    }

    barChart = {
        container: "#barChart",
        titleSelector: "#barTitle",
        titleTxt: "Working Hours Per Day",
        panel: {
            container: "#barChartContainer",
            chart: "#barChartContainer .chart",
        }
    }

    dayChart = {
        container: "#doughnutDayChart",
        titleSelector: "#dayTitle",
        titleTxt: "Daily Work (12h Limit)",
        panel: {
            container: "#doughnutDayChartContainer",
            chart: "#doughnutDayChartContainer canvas",
        }
    }

    weekChart = {
        container: "#doughnutWeekChart",
        titleSelector: "#weekTitle",
        titleTxt: "Weekly Work (35h Limit)",
        panel: {
            container: "#doughnutWeekChartContainer",
            chart: "#doughnutWeekChartContainer canvas",
        }
    }

    editUserPopup = {
        container: "#editUserPopup",
        closeBtn: "#closeEditUserPopup",

        titleSelector: "#editUserPopupTitle",
        titleTxt: "Edit User Informations",
        
        usernameLabelSelector: "#editUsernameLabel",
        usernameLabelTxt: "Username",
        usernameInput: "#editUsernameInput",
        
        emailLabelSelector: "#editEmailLabel",
        emailLabelTxt: "Email",
        emailInput: "#editEmailInput",
        
        pwdLabelSelector: "#editPwdLabel",
        pwdLabelTxt: "Password",
        pwdInput: "#editPwdInput",
        
        updateBtn: "#updateUserBtn",
        deleteBtn: "#deleteUserBtn",
        deleteUserPopup: {
            container: "#deleteUserPopup",
            titleSelector: "#deleteUserTitle",
            titleTxt: "Confirm Account Deletion",
            closeBtn: "#closeDeleteUserPopup",
            contentSelector: "#deleteUserContent",
            contentTxt: "Are you sure you want to delete your account? This action cannot be undone.",
            cancelBtn: "#deleteUserCancelBtn",
            confirmBtn: "#deleteUserConfirmBtn",
        }
    }
}

export default new DashboardPOM()