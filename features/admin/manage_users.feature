フィーチャ: ユーザ管理
  管理者ユーザはSKIP Wikiのユーザを管理できるようにしたい

  背景:
    前提 言語は"ja_JP"
    かつ ユーザ"dammyadmin"を管理者として登録し、ログインする
    かつ ノート"a_note"が作成済みである
    もし トップページを表示している

  シナリオ: 管理者ユーザは管理者メニューにアクセスできる
    ならば "システムの設定"と表示されていること

  シナリオ: ユーザ一覧画面に遷移する
    もし  "システムの設定"リンクをクリックする
    ならば "メニュー"と表示されていること
    ならば "ノート一覧"と表示されていること
    ならば "ページ一覧"と表示されていること
    ならば "ファイル一覧"と表示されていること
    ならば "ユーザ一覧"と表示されていること
    ならば "ユーザ識別子"と表示されていること
    ならば "dammyadmin"と表示されていること

  シナリオ: ユーザ編集
    もし  "システムの設定"リンクをクリックする
    かつ  "編集"リンクをクリックする

    もし  "ユーザ識別子"に"hoge"と入力する
    かつ  "ユーザ名"に"moge"と入力する
    かつ  "管理者"をチェックする
    かつ  "更新"ボタンをクリックする

    ならば  "ユーザ一覧"と表示されていること
    ならば  "moge"と表示されていること

