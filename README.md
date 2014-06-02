# Twitter OAuth Sample

TwitterのOAuth認証のサンプルです。
OAuth認証の動作を確認することができます。

Sinatraと[Ruby OAuth](https://github.com/pelle/oauth)を利用しています。

## Process

1. リクエストトークンを取得する
2. 認証用URLにユーザをリダイレクトさせる
3. リクエストトークンからアクセストークンを取得する

3のアクセストークンを用いることで、Twitterの[REST API](https://dev.twitter.com/docs/api/1.1)を叩くことができるようになります。
