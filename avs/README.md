！[]（../../维基/资产/ Alexa的标志 - 3.png）

＃＃ 关于该项目

该项目提供了一个逐步的演练，帮助您在60分钟内建立一个**免提** [Alexa Voice Service]（https://developer.amazon.com/avs）（AVS）原型，使用唤醒来自[Sensory]（https://github.com/Sensory/alexa-rpi）或[KITT.AI]（https://github.com/Kitt-AI/snowboy）的单词引擎。现在，除了按一个按钮“开始听”之外，你现在还可以说“Alexa”的唤醒词，很像[Amazon Echo]（https://amazon.com/echo）。您可以在[Raspberry Pi]（../../ wiki / Raspberry-Pi）上找到分步说明来设置免提原型，或按照说明设置即按即说原型在[Linux]（../../ wiki / Linux），[Mac]（../../维基/ Mac）或[Windows]（../../维基/ Windows）上。

---

##什么是AVS？

[Alexa语音服务]（https://developer.amazon.com/avs）（AVS）是亚马逊的智能语音识别和自然语言理解服务，可让您作为开发人员对任何具有麦克风和扬声器的连接设备进行语音启用。

---

##开始吧

您可以在以下平台上设置此项目 - 

* [Raspberry Pi]（../../ wiki / Raspberry-Pi），或
* [Linux]（../../ wiki / Linux），或
* [Mac]（../../维基/ Mac），或
* [Windows]（../../ wiki / Windows）

或者您可以使用这些第三方开发套件进行原型设计 - 

* *新！* [亚马逊AVS的Raspberry Pi + Microsemi AcuEdge开发套件]（https://github.com/MicrosemiVoiceProcessing/ZLK38AVS/wiki/howto）
* [Raspberry Pi +亚马逊AVS的Conexant 4-mic开发套件]（https://github.com/conexant/alexa-avs-sample-app/wiki/Conexant4Mic-Raspberry-Pi）
* [Raspberry Pi +亚马逊AVS的Conexant 2-Mic开发套件]（../../ wiki / Conexant2Mic-Raspberry-Pi）

---

＃＃ 什么是新的？

** 2017年6月21日：**

*更新*

*示例应用程序现在支持显示卡。
  *“TemplateRuntime”指令将以示例应用程序的形式显示为JSON。
  *启用显示卡：
    *登录到[Amazon Developer Portal]（https://developer.amazon.com/login.html），浏览您的产品：** Alexa> AVS **。
    *单击**编辑**，然后单击**设备功能**。
    *选择**显示卡**，然后选择**显示卡与媒体**。

** 2017年5月31日：**

*更新*

*亚马逊AVS的Raspberry Pi + Microsemi AcuEdge开发套件现已可供购买。 [了解详情»]（https://developer.amazon.com/alexa-voice-service/dev-kits/microsemi-acuedge/）

** 2017年5月4日：**

*更新*

*亚马逊AVS的Conexant 4-mic开发套件现已推出，通过Amazon Alexa构建远程产品，可以更轻松，更具成本效益。 [了解更多»]（http://developer.amazon.com/alexa-voice-service/dev-kits/conexant-4-mic/）

** 2017年4月27日：**

*更新*

*需要帮助解决AVS样本应用程序？查看新的[疑难解答指南]（https://github.com/alexa/alexa-avs-sample-app/wiki/Troubleshooting）。

** 2017年4月20日：**

*更新*

*伴随服务在重新启动之间保持刷新令牌。这意味着您每次启动示例应用程序时都不必进行身份验证。阅读关于[Alexa Blog»]的更新（https://developer.amazon.com/blogs/alexa/post/bb4a34ad-f805-43d9-bbe0-c113105dd8fd/understanding-login-authentication-with-the-avs-样品应用内 - 和 - 所述节点-JS-服务器）。
* ** Listen **按钮已被麦克风图标替换。
*示例应用程序使用来自KITT.ai的新的Alexa唤醒字模型。

*保养*

*“POM.xml”中更新了ALPN版本。
*自动安装不再需要用户干预来更新证书。

*Bug修复*

*示例应用程序确保在发送初始“SynchronizeState”事件之前建立下行通道流。这符合[管理与AVS的HTTP / 2连接]中提供的指导（https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/docs/managing-an-http-2-连接）。
*示例应用程序用户界面中的区域设置字符串已更新，以匹配“config.json”中的值。
*修正了Linux错误中没有卷。
* ** WiringPi **现在安装为“automated_install.sh”的一部分。
*修正了100％的CPU错误。

*已知的问题*

*要退出java示例应用程序，您必须删除`/ samples / companionService`文件夹中的`refresh_tokens`文件。否则，示例应用将在每次重新启动时进行身份验证。 [点击此处注销说明]（../../ wiki / Sample-App-Log-Out-Instructions）。

---

##重要注意事项

*查看AVS [条款和协议]（https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/support/terms-and-agreements）。

*与样品项目相关的耳环仅适用于**原型设计**。有关商业产品的实施和设计指导，请参阅[AVS设计]（https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/content/designing-for-the-alexa-voice服务）和[AVS UX指南]（https://developer.amazon.com/public/solu
