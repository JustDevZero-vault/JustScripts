# Telegram bot

This script is from the [Zabbix-in-Telegram](https://github.com/ableev/Zabbix-in-Telegram/) repository which I use for my Zabbix servers, and since it works so well I will use the bash version for other scripts.

To obtain support or information of how to use it for Zabbix please go to the original repository.

All credit goes to @ableev and the people who contributes to the project.

* You can use the following command to send a message from your command line: </br>
`./zbxtg.py "<username>" "<message_subject>" "<message_body>" --debug`
 * For `<username>` substitute your Telegram username, NOT that of your bot (case-sensitive)
 * For `<message_subject>` and `<message_body>` just substitute something like "test" "test" (for Telegram it's doesn't matter between subject and body
 * You can omit the `"`, these are optional
