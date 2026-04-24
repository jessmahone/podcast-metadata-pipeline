with source as (

    select * from {{ source('raw', 'trending_feeds') }}

),

podcast_categories as (

    select
        id          as podcast_id,
        queried_category

    from source

)

select * from podcast_categories