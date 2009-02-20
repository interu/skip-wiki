フィーチャ: アクセス管理
  複数ユーザからノートやページに対するアクセス制御をしたい

  シナリオ: ノートの作成者はノートへアクセスできる
    前提   言語は"ja-JP"
    かつ   ユーザ"alice"を登録し、ログインする
    かつ   ノート"a_note"が作成済みである

    もし  ノート"a_note"のページ"FrontPage"を表示している
    かつ  ナビゲーションメニューから"プロパティを編集"を選択する
    かつ  "公開日時"に"2005-12-01"と入力する
    かつ  "ページを更新"ボタンをクリックする
    かつ  再読み込みする

    ならば "SKIP Noteへようこそ"と表示されていること

  シナリオ: 公開ノート情報はグループ外のユーザはアクセスできない
    前提シナリオ ノートの作成者はノートへアクセスできる
    もし   "ログアウト"リンクをクリックする
    かつ   ユーザ"bob"を登録し、ログインする
    かつ   ノート"a_note"の情報を表示している
    ならば "ページが存在しない、またはアクセスする権限がありません。"と表示されていること

  シナリオ: 公開ノートのページはグループ外のユーザからもアクセスできる
    前提シナリオ 公開ノート情報はグループ外のユーザはアクセスできない
    もし   ノート"a_note"のページ"FrontPage"を表示している
    ならば "SKIP Noteへようこそ"と表示されていること

    もし   "ページ一覧"リンクをクリックする
    ならば "FrontPage"と表示されていること
    かつ   "履歴を表示"と表示されていないこと

  シナリオ: 公開ノートのページであっても公開前のページはグループ外のユーザはアクセスできない
    前提シナリオ ノートの作成者はノートへアクセスできる
    もし  ノート"a_note"のページ"FrontPage"を表示している
    かつ  ナビゲーションメニューから"プロパティを編集"を選択する
    かつ  "公開日時"に"2010-12-01"と入力する
    かつ  "ページを更新"ボタンをクリックする
    かつ  再読み込みする
    かつ  "ログアウト"リンクをクリックする
    かつ  ユーザ"bob"を登録し、ログインする
    かつ  ノート"a_note"のページ"FrontPage"を表示している
    ならば "ページが存在しない、またはアクセスする権限がありません。"と表示されていること

  シナリオ: 非公開ノートのノート情報はグループ外ユーザからはアクセスできない
    前提シナリオ ノートの作成者はノートへアクセスできる
    もし   ナビゲーションメニューから"ノート情報"を選択する
    かつ   "ノートのプロパティを編集"リンクをクリックする
    かつ   "メンバーのみが読み書きできる"を選択する
    かつ   "更新"ボタンをクリックする
    かつ   再読み込みする
    かつ   "ログアウト"リンクをクリックする
    かつ   ユーザ"bob"を登録し、ログインする
    もし   ノート"a_note"の情報を表示している
    ならば "ページが存在しない、またはアクセスする権限がありません。"と表示されていること

  シナリオ: 非公開ノートのページはグループ外ユーザはアクセスできない
    前提シナリオ 非公開ノートのノート情報はグループ外ユーザからはアクセスできない
    もし   ノート"a_note"のページ"FrontPage"を表示している
    ならば "ページが存在しない、またはアクセスする権限がありません。"と表示されていること

  シナリオ: 管理者権限を持っていないユーザは管理者メニューにアクセスできない
    前提シナリオ ノートの作成者はノートへアクセスできる
    もし         ノート"a_note"のページ"FrontPage"を表示している
    ならば       "管理者メニュー"と表示されていないこと

  シナリオ: 管理者ユーザは管理者メニューにアクセスできる
    前提 言語は"ja_JP"
    かつ ユーザ"dammyadmin"を管理者として登録し、ログインする
    かつ ノート"a_note"が作成済みである
    もし ノート"a_note"のページ"FrontPage"を表示している
    ならば "管理者メニュー"と表示されていること
