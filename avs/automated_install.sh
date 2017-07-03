#!/bin/bash

#-------------------------------------------------------
# 从下面的developer.amazon.com粘贴
#-------------------------------------------------------

# 这是在Amazon开发人员门户中为您的设备或移动应用程序提供的名称。 要查看此内容，请转到https://developer.amazon.com/edw/home.html。 它可能被标记为设备类型ID。
ProductID=YOUR_PRODUCT_ID_HERE

#从开发人员控制台中的网络设置标签中检索您的客户端ID：https：//developer.amazon.com/edw/home.html
ClientID=YOUR_CLIENT_ID_HERE

# 从开发人员控制台的网页设置标签中检索您的客户端密码：https：//developer.amazon.com/edw/home.html
ClientSecret=YOUR_CLIENT_SECRET_HERE

#-------------------------------------------------------
# 不需要改变下面的任何东西...
#-------------------------------------------------------

#-------------------------------------------------------
# 预先填充测试。 随意改变。
#-------------------------------------------------------

# 你的国家。 必须是2个字符！
Country='US'
# 你的州。 必须是2个以上的字符。
State='WA'
# 您的城市。不能是空白的。
City='SEATTLE'
# 您的组织名称/公司名称。 不能是空白的。
Organization='AVS_USER'
# 您的设备序列号。 不能空白，但可以是任意组合的字符。
DeviceSerialNumber='123456789'
# 您的密钥存储密码 我们建议留下这个空白进行测试。
KeyStorePassword=''

#-------------------------------------------------------
# 解析用户输入的功能。
#-------------------------------------------------------
# 参数是：Yes-Enabled不启用退出启用
YES_ANSWER=1
NO_ANSWER=2
QUIT_ANSWER=3
parse_user_input()
{
  if [ "$1" = "0" ] && [ "$2" = "0" ] && [ "$3" = "0" ]; then
    return
  fi
  while [ true ]; do
    Options="["
    if [ "$1" = "1" ]; then
      Options="${Options}y"
      if [ "$2" = "1" ] || [ "$3" = "1" ]; then
        Options="$Options/"
      fi
    fi
    if [ "$2" = "1" ]; then
      Options="${Options}n"
      if [ "$3" = "1" ]; then
        Options="$Options/"
      fi
    fi
    if [ "$3" = "1" ]; then
      Options="${Options}quit"
    fi
    Options="$Options]"
    read -p "$Options >> " USER_RESPONSE
    USER_RESPONSE=$(echo $USER_RESPONSE | awk '{print tolower($0)}')
    if [ "$USER_RESPONSE" = "y" ] && [ "$1" = "1" ]; then
      return $YES_ANSWER
    else
      if [ "$USER_RESPONSE" = "n" ] && [ "$2" = "1" ]; then
        return $NO_ANSWER
      else
        if [ "$USER_RESPONSE" = "quit" ] && [ "$3" = "1" ]; then
          printf "\n再见.\n\n"
          exit
        fi
      fi
    fi
    printf "请输入有效的回复.\n"
  done
}

#----------------------------------------------------------------
# 用于在多个选项之间选择用户偏好的功能
#----------------------------------------------------------------
# 参数是：result_var option1 option2 ...
select_option()
{
  local _result=$1
  local ARGS=("$@")
  if [ "$#" -gt 0 ]; then
      while [ true ]; do
         local count=1
         for option in "${ARGS[@]:1}"; do
            echo "$count) $option"
            ((count+=1))
         done
         echo ""
         local USER_RESPONSE
         read -p "请选择一个选项 [1-$(($#-1))] " USER_RESPONSE
         case $USER_RESPONSE in
             ''|*[!0-9]*) echo "请提供有效的号码"
                          continue
                          ;;
             *) if [[ "$USER_RESPONSE" -gt 0 && $((USER_RESPONSE+1)) -le "$#" ]]; then
                    local SELECTION=${ARGS[($USER_RESPONSE)]}
                    echo "选择: $SELECTION"
                    eval $_result=\$SELECTION
                    return
                else
                    clear
                    echo "请选择一个有效的选项"
                fi
                ;;
         esac
      done
  fi
}

#-------------------------------------------------------
# 检索用户帐户凭据的功能
#-------------------------------------------------------
# 参数是：用户输入的预期长度
Credential=""
get_credential()
{
  Credential=""
  read -p ">> " Credential
  while [ "${#Credential}" -lt "$1" ]; do
    echo "输入长度无效."
    echo "请再试一次."
    read -p ">> " Credential
  done
}

#-------------------------------------------------------
# 用于确认用户凭据的功能。
#-------------------------------------------------------
check_credentials()
{
  clear
  echo "====== AVS + Raspberry Pi用户凭证======"
  echo ""
  echo ""
  if [ "${#ProductID}" -eq 0 ] || [ "${#ClientID}" -eq 0 ] || [ "${#ClientSecret}" -eq 0 ]; then
    echo "至少需要一个所需凭据（ProductID，ClientID或ClientSecret）。"
    echo ""
    echo ""
    echo "这些值可以在这里找到https://developer.amazon.com/edw/home.html，现在修复一下？"
    echo ""
    echo ""
    parse_user_input 1 0 1
  fi

  # 列出变量并验证用户输入
  if [ "${#ProductID}" -ge 1 ] && [ "${#ClientID}" -ge 15 ] && [ "${#ClientSecret}" -ge 15 ]; then
    echo "ProductID >> $ProductID"
    echo "ClientID >> $ClientID"
    echo "ClientSecret >> $ClientSecret"
    echo ""
    echo ""
    echo "这些信息是否正确？"
    echo ""
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
      return
    fi
  fi

  clear
  # 检查ProductID
  NeedUpdate=0
  echo ""
  if [ "${#ProductID}" -eq 0 ]; then
    echo "您的ProductID未设置"
    NeedUpdate=1
  else
    echo "您的ProductID设置为: $ProductID."
    echo "这些信息是否正确？"
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      NeedUpdate=1
    fi
  fi
  if [ $NeedUpdate -eq 1 ]; then
    echo ""
    echo "此值应与您在https://developer.amazon.com/edw/home.html上输入的ProductID（或设备类型ID）相匹配。"
    echo "信息位于设备类型信息下"
    echo "例如：RaspberryPi3"
    get_credential 1
    ProductID=$Credential
  fi

  echo "-------------------------------"
  echo "ProductID设置为 >> $ProductID"
  echo "-------------------------------"

  # 检查ClientID
  NeedUpdate=0
  echo ""
  if [ "${#ClientID}" -eq 0 ]; then
    echo "您的ClientID未设置"
    NeedUpdate=1
  else
    echo "您的ClientID设置为: $ClientID."
    echo "这些信息是否正确？"
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      NeedUpdate=1
    fi
  fi
  if [ $NeedUpdate -eq 1 ]; then
    echo ""
    echo "请输入您的ClientID。"
    echo "此值应与https://developer.amazon.com/edw/home.html上的信息相匹配。"
    echo "信息位于“安全性配置文件”选项卡下。"
    echo "例如：amzn1.application-oa2-client.xxxxxxxx"
    get_credential 28
    ClientID=$Credential
  fi

  echo "-------------------------------"
  echo "ClientID设置为 >> $ClientID"
  echo "-------------------------------"

  # 检查ClientSecret
  NeedUpdate=0
  echo ""
  if [ "${#ClientSecret}" -eq 0 ]; then
    echo "您的ClientSecret未设置"
    NeedUpdate=1
  else
    echo "您的ClientSecret设置为: $ClientSecret."
    echo "这些信息是否正确？"
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      NeedUpdate=1
    fi
  fi
  if [ $NeedUpdate -eq 1 ]; then
    echo ""
    echo "请输入您的ClientSecret。"
    echo "此值应与https://developer.amazon.com/edw/home.html上的信息相匹配。"
    echo "信息位于“安全性配置文件”选项卡下。"
    echo "例如：fxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa"
    get_credential 20
    ClientSecret=$Credential
  fi

  echo "-------------------------------"
  echo "ClientSecret设置为 >> $ClientSecret"
  echo "-------------------------------"

  check_credentials
}

#-------------------------------------------------------
# 将用户提供的值插入到模板文件中
#-------------------------------------------------------
# 参数是：template_directory，template_name，target_name
use_template()
{
  Template_Loc=$1
  Template_Name=$2
  Target_Name=$3
  while IFS='' read -r line || [[ -n "$line" ]]; do
    while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]]; do
      LHS=${BASH_REMATCH[1]}
      RHS="$(eval echo "\"$LHS\"")"
      line=${line//$LHS/$RHS}
    done
    echo "$line" >> "$Template_Loc/$Target_Name"
  done < "$Template_Loc/$Template_Name"
}

#-------------------------------------------------------
# 在安装脚本运行之前检查脚本是否全部
#-------------------------------------------------------
clear
echo "====== AVS + Raspberry Pi许可证和协议======"
echo ""
echo ""
echo "该代码库依赖于几个外部库和虚拟环境，如Kitt-Ai，Sensory，ALSA，Atlas，Portaudio，VLC，NodeJS，npm，Oracle JDK，OpenSSL，Maven＆CMake。"
echo ""
echo "请从示例应用程序存储库中读取文档“Installer_Licenses.txt”以及上述相应的许可证。"
echo ""
echo "您是否同意第三方来源的必要软件的条款和条件，并希望从第三方来源下载必要的软件？"
echo ""
echo ""
echo "======================================================="
echo ""
echo ""
parse_user_input 1 0 1

clear
echo "=============== AVS + Raspberry Pi安装程序 =========="
echo ""
echo ""
echo "欢迎来到AVS + Raspberry Pi安装程序。"
echo "如果您没有Amazon开发者帐户，请注册一个"
echo "网址为：https：//developer.amazon.com/edw/home.html，并按照"
echo "指令，以创建一个AVS设备或应用程序。"
echo ""
echo ""
echo "======================================================="
echo ""
echo ""
echo "你有亚马逊开发者账户吗？"
echo ""
echo ""
parse_user_input 1 1 1
USER_RESPONSE=$?
if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
  clear
  echo "======注册亚马逊开发者帐号======="
  echo ""
  echo ""
  echo "请注册一个Amazon开发者帐户\ nat https://developer.amazon.com/edw/home.html，然后再继续。"
  echo ""
  echo ""
  echo "准备继续吗？"
  echo ""
  echo ""
  echo "======================================================="
  echo ""
  echo ""
  parse_user_input 1 0 1
fi


#--------------------------------------------------------------------------------------------
# 检查使用ProductID，ClientID和ClientSecret的用户是否更新了脚本
#--------------------------------------------------------------------------------------------

if [ "$ProductID" = "YOUR_PRODUCT_ID_HERE" ]; then
  ProductID=""
fi
if [ "$ClientID" = "YOUR_CLIENT_ID_HERE" ]; then
  ClientID=""
fi
if [ "$ClientSecret" = "YOUR_CLIENT_SECRET_HERE" ]; then
  ClientSecret=""
fi

check_credentials

# 预配置的变量
OS=rpi
User=$(id -un)
Group=$(id -gn)
Origin=$(pwd)
Samples_Loc=$Origin/samples
Java_Client_Loc=$Samples_Loc/javaclient
Wake_Word_Agent_Loc=$Samples_Loc/wakeWordAgent
Companion_Service_Loc=$Samples_Loc/companionService
Kitt_Ai_Loc=$Wake_Word_Agent_Loc/kitt_ai
Sensory_Loc=$Wake_Word_Agent_Loc/sensory
External_Loc=$Wake_Word_Agent_Loc/ext
Locale="en-US"

mkdir $Kitt_Ai_Loc
mkdir $Sensory_Loc
mkdir $External_Loc


# 选择一个区域设置
clear
echo "====设置区域设置====="
echo ""
echo ""
echo "你想要使用哪个区域？"
echo ""
echo ""
echo "======================================================="
echo ""
echo ""
select_option Locale "en-US" "en-GB" "de-DE"

# 强制音频纠正输出
clear
echo "====设置音频输出====="
echo ""
echo ""
echo "您是否使用3.5mm插孔或HDMI电缆进行音频输出？"
echo ""
echo ""
echo "======================================================="
echo ""
echo ""
select_option audio_output "3.5mm jack" "HDMI audio output"
if [ "$audio_output" == "3.5mm jack" ]; then
  sudo amixer cset numid=3 1
  echo "音频强制为3.5mm插孔"
else
  sudo amixer cset numid=3 2
  echo "音频强制HDMI"
fi

Wake_Word_Detection_Enabled="true"
# 检查用户是否要启用Wake Word“Alexa”检测
clear
echo "===启用免提体验使用唤醒词\”Alexa \“===="
echo ""
echo ""
echo "您要启用”Alexa“”唤醒字检测“吗？"
echo ""
echo ""
echo "======================================================="
echo ""
echo ""
parse_user_input 1 1 1
USER_RESPONSE=$?
if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
  Wake_Word_Detection_Enabled="false"
fi

echo ""
echo ""
echo "==============================================="
echo " 确保我们正在安装到正确的操作系统"
echo "==============================================="
echo ""
echo ""
echo "===========安装Oracle Java8 ==========="
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
chmod +x $Java_Client_Loc/install-java8.sh
cd $Java_Client_Loc && bash ./install-java8.sh
cd $Origin

echo ""
echo ""
echo "==============================="
echo "*******************************"
echo "***开始安装***"
echo "**这可能需要一段时间**"
echo "   *************************"
echo "   ========================="
echo ""
echo ""

# 安装依赖关系
echo "==========更新能力==========="
sudo apt-get update
sudo apt-get upgrade -yq

echo "==========安装Git ============"
sudo apt-get install -y git

echo "==========获取Kitt-Ai的代码==========="
cd $Kitt_Ai_Loc
git clone https://github.com/Kitt-AI/snowboy.git

echo "==========获取Sensory的代码==========="
cd $Sensory_Loc
git clone https://github.com/Sensory/alexa-rpi.git

cd $Origin

echo "==========安装Kitt-Ai和Sensory的库：ALSA，Atlas ==========="
sudo apt-get -y install libasound2-dev
sudo apt-get -y install libatlas-base-dev
sudo ldconfig

echo "==========安装WiringPi ==========="
sudo apt-get -y install wiringpi
sudo ldconfig

echo "==========安装VLC和相关的环境变量=========="
sudo apt-get install -y vlc vlc-nox vlc-data
#确保可以找到库
sudo sh -c "echo \"/usr/lib/vlc\" >> /etc/ld.so.conf.d/vlc_lib.conf"
sudo sh -c "echo \"VLC_PLUGIN_PATH=\"/usr/lib/vlc/plugin\"\" >> /etc/environment"
sudo ldconfig

echo "==========安装NodeJS =========="
sudo apt-get install -y nodejs npm build-essential
sudo ln -s /usr/bin/nodejs /usr/bin/node
node -v
sudo ldconfig

echo "==========安装Maven =========="
sudo apt-get install -y maven
mvn -version
sudo ldconfig

echo "==========安装OpenSSL并生成自签名证书=========="
sudo apt-get install -y openssl
sudo ldconfig

echo "==========下载并构建Kitt-Ai Snowboy所需的Port Audio Library =========="
cd $Kitt_Ai_Loc/snowboy/examples/C++
bash ./install_portaudio.sh
sudo ldconfig
cd $Kitt_Ai_Loc/snowboy/examples/C++
make -j4
sudo ldconfig
cd $Origin

echo "==========生成ssl.cnf =========="
if [ -f $Java_Client_Loc/ssl.cnf ]; then
  rm $Java_Client_Loc/ssl.cnf
fi
use_template $Java_Client_Loc template_ssl_cnf ssl.cnf

echo "==========生成generate.sh =========="
if [ -f $Java_Client_Loc/generate.sh ]; then
  rm $Java_Client_Loc/generate.sh
fi
use_template $Java_Client_Loc template_generate_sh generate.sh

echo "==========执行generate.sh =========="
chmod +x $Java_Client_Loc/generate.sh
cd $Java_Client_Loc && bash ./generate.sh
cd $Origin

echo "==========配置随播服务=========="
if [ -f $Companion_Service_Loc/config.js ]; then
  rm $Companion_Service_Loc/config.js
fi
use_template $Companion_Service_Loc template_config_js config.js

echo "==========配置Java客户端=========="
if [ -f $Java_Client_Loc/config.json ]; then
  rm $Java_Client_Loc/config.json
fi
use_template $Java_Client_Loc template_config_json config.json

echo "==========配置ALSA设备=========="
if [ -f /home/$User/.asoundrc ]; then
  rm /home/$User/.asoundrc
fi
printf "pcm.!default {\n  type asym\n   playback.pcm {\n     type plug\n     slave.pcm \"hw:0,0\"\n   }\n   capture.pcm {\n     type plug\n     slave.pcm \"hw:1,0\"\n   }\n}" >> /home/$User/.asoundrc

echo "==========安装CMake =========="
sudo apt-get install -y cmake
sudo ldconfig

echo "==========安装Java Client =========="
if [ -f $Java_Client_Loc/pom.xml ]; then
  rm $Java_Client_Loc/pom.xml
fi
cp $Java_Client_Loc/pom_pi.xml $Java_Client_Loc/pom.xml
cd $Java_Client_Loc && mvn validate && mvn install && cd $Origin

echo "==========安装伴侣服务=========="
cd $Companion_Service_Loc && npm install && cd $Origin

echo "==========准备外部依赖关系唤醒Word Agent =========="
mkdir $External_Loc/include
mkdir $External_Loc/lib
mkdir $External_Loc/resources

cp $Kitt_Ai_Loc/snowboy/include/snowboy-detect.h $External_Loc/include/snowboy-detect.h
cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/portaudio.h $External_Loc/include/portaudio.h
cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/pa_ringbuffer.h $External_Loc/include/pa_ringbuffer.h
cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/pa_util.h $External_Loc/include/pa_util.h
cp $Kitt_Ai_Loc/snowboy/lib/$OS/libsnowboy-detect.a $External_Loc/lib/libsnowboy-detect.a
cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/lib/libportaudio.a $External_Loc/lib/libportaudio.a
cp $Kitt_Ai_Loc/snowboy/resources/common.res $External_Loc/resources/common.res
cp $Kitt_Ai_Loc/snowboy/resources/alexa/alexa-avs-sample-app/alexa.umdl $External_Loc/resources/alexa.umdl

sudo ln -s /usr/lib/atlas-base/atlas/libblas.so.3 $External_Loc/lib/libblas.so.3

$Sensory_Loc/alexa-rpi/bin/sdk-license file $Sensory_Loc/alexa-rpi/config/license-key.txt $Sensory_Loc/alexa-rpi/lib/libsnsr.a $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-20500.snsr $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-21000.snsr $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-31000.snsr
cp $Sensory_Loc/alexa-rpi/include/snsr.h $External_Loc/include/snsr.h
cp $Sensory_Loc/alexa-rpi/lib/libsnsr.a $External_Loc/lib/libsnsr.a
cp $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-31000.snsr $External_Loc/resources/spot-alexa-rpi.snsr

mkdir $Wake_Word_Agent_Loc/tst/ext
cp -R $External_Loc/* $Wake_Word_Agent_Loc/tst/ext
cd $Origin

echo "==========编译唤醒字代理=========="
cd $Wake_Word_Agent_Loc/src && cmake . && make -j4
cd $Wake_Word_Agent_Loc/tst && cmake . && make -j4

chown -R $User:$Group $Origin
chown -R $User:$Group /home/$User/.asoundrc

echo ""
echo '============================='
echo '*****************************'
echo '========= 完成 =========='
echo '*****************************'
echo '============================='
echo ""

Number_Terminals=2
if [ "$Wake_Word_Detection_Enabled" = "true" ]; then
  Number_Terminals=3
fi
echo "要运行演示，请在 $Number_Terminals 分隔终端中执行以下操作:"
echo "运行配套服务: cd $Companion_Service_Loc && npm start"
echo "运行AVS Java Client: cd $Java_Client_Loc && mvn exec:exec"
if [ "$Wake_Word_Detection_Enabled" = "true" ]; then
  echo "运行唤醒字代理: "
  echo "  Sensory: cd $Wake_Word_Agent_Loc/src && ./wakeWordAgent -e sensory"
  echo "  KITT_AI: cd $Wake_Word_Agent_Loc/src && ./wakeWordAgent -e kitt_ai"
  echo "  GPIO: 请注意 - 如果使用此选项，请以sudo运行唤醒字代理:"
  echo "  cd $Wake_Word_Agent_Loc/src && sudo ./wakeWordAgent -e gpio"
fi
