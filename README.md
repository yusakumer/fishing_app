# ER図

```mermaid
erDiagram

users ||--o{ fishing_logs : "has_many"
prefectures ||--o{ users : "has_many/belongs_to"

fish_species ||--o{fishing_logs : "has_many/belongs_to"


users {
    string name "null:false"
    string introduction "null:true"
    int prefecture_id FK "null:false"
}

fishing_logs {
    int id PK
    int user_id FK "null:false"
    int fish_species_id FK "null:false"
    decimal size "任意"
    decimal latitude  "null:false"
    decimal longitude "null:false"
    datetime fished_at "null:false"
    string lure "任意"
    string memo　"任意"
    string weather　"null:false"
    string tide "null:false"
}

fish_species {
    int id PK
    string name UK "null:false"
    boolean is_marine "default:true"
}

prefectures {
    int id PK
    string prefecture UK
}


```

- 写真管理はActive Storageを使用しています
- usersテーブルについても、Deviseを使用しているため、追加カラムだけ記載しています。
