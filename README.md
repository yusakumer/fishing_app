# 技術選定
## Ruby
## Ruby on Rails
## React
## Doker


```mermaid
erDiagram

    prefectures ||--o{ users : "has_many / belongs_to"
    users ||--o{ fishing_logs : "has_many / belongs_to"
    fish_species ||--o{ fishing_logs : "has_many / belongs_to"
    lure_categories ||--o{ lure_types : "has_many / belongs_to"
    lure_categories ||--o{ fishing_logs : "has_many / belongs_to"
    water_types ||--o{ fishing_logs : "has_many / belongs_to"

    prefectures {
        int id PK
        string name UK
    }

    users {
        int prefecture_id FK
        string name
        string introduction
    }

    fishing_logs {
        int id PK
        int user_email FK
        int fish_species_id FK
        int lure_type_id FK
        int water_type_id FK
        int size
        decimal latitude
        decimal longitude
        datetime fished_at
        text memo
        string weather
        string tide
    }

    fish_species {
        int id PK
        string name UK
    }

    lure_categories {
        int id PK
        string name UK
    }

    lure_types {
        int id PK
        int lure_category_id FK
        string name UK
    }

    water_types {
        int id PK
        string name UK
    }
```
devise使用しているため、userテーブルにはemailを追記してません
usersテーブル、fishing_logsについては、ActiveStorageを使用しているため、カラムには追記していません