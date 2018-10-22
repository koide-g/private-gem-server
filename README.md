# Private Gem Server

using geminabox


## Usage

```
$ bundle install
$ bundle exec rackup
INFO  WEBrick 1.3.1
INFO  ruby 2.4.4
INFO  WEBrick::HTTPServer#start: pid=8621 port=9292
```

## ENV

| Key | Description |
| :-- | :-- |
| IP_ADDRESS_WHITELIST | 社内IPアドレス 複数の場合スペース区切り、サブネットマスク表記にも対応する BASIC認証不要 |
| IP_ADDRESS_WHITELIST_REMOTE | 社外有効IPアドレス 複数の場合スペース区切り、サブネットマスク表記にも対応する 要BASIC認証 |
| BASIC_AUTH_USER | BASIC認証ユーザ名 |
| BASIC_AUTH_PASSWORD | BASIC認証パスワード |
| GEMINABOX_DATA_DIR | データ |
