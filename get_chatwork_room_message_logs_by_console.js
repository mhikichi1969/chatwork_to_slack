//
// 取得したいルームをブラウザで開き、consoleにコードをペーストして実行
// スクリプトの仕様上、最新の発言が読み込まれている状態で実行するのが良いです
//

// 現在のURLをパースしてホスト名とルームIDを変数にする
let HOST_URL = document.location.href.replace(/https?:\/\/([^/]+).+rid([\d]+)/, '$1');
let target_room_id = document.location.href.replace(/https?:\/\/([^/]+).+rid([\d]+)/, '$2');
// 取得したいチャットルームの最新のチャット ID
var target_chat_id = 0;
document.querySelectorAll('[data-mid]').forEach(function(elem){if(target_chat_id < elem.dataset.mid) target_chat_id=elem.dataset.mid});
// 最大再帰回数. 本番時は 10000 程度を指定してください.
var LIMIT_COUNT = 10000;
// 通信間隔[ミリ秒].
var INTERVAL_TIME = 100;

var message_logs = []
console.log('host url: ' + HOST_URL + ', target_room_id: ' + target_room_id)
function log(room_id, first_chat_id, count, callback)
{
  if (count <= 0)
  {
    callback();
    return;
  }
  var token = ACCESS_TOKEN;
  var myid = MYID;
  var url = `https://${HOST_URL}/gateway/load_old_chat.php?myid=${myid}&_v=1.80a&_av=5&ln=ja&room_id=${room_id}&first_chat_id=${first_chat_id}`;
  var request = new XMLHttpRequest();
  console.log('request url: ' + url);
  request.open('POST', url);
  request.onreadystatechange = function (){
    if (request.readyState != 4) {
      // リクエスト中
    } else if (request.status != 200) {
      // 失敗
    } else {
      console.log(request.responseText);
      var text = request.responseText;
      var json = JSON.parse(text);
      console.log(count);
      var chat_list = json["result"]["chat_list"];
      console.log(chat_list);
      if (chat_list.length == 0)
      {
        callback();
        return;
      }
      var chat_messages = chat_list.filter(item => item["msg"] != null);
      chat_messages.forEach(item => {
        message_logs.push(item)
      });
      var last_chat_id = (chat_list[chat_list.length - 1]["id"]);
      setTimeout(() =>
      {
        log(room_id, last_chat_id, count - 1, callback);


      }, INTERVAL_TIME);
    }
  };

  var formData = new FormData();
  formData.append("pdata", '{"_t":"' + token + '"}');
  request.send(formData);
}

var callback = function()
{
  message_logs.sort((a, b) => {
    return Number(a["id"]) - Number(b["id"]);
  });
  var all_message = JSON.stringify(message_logs);
  console.log(all_message);
};

log(target_room_id, target_chat_id, LIMIT_COUNT, callback);