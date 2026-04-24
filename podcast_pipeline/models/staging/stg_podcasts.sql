with source as (

    select * from {{ source('raw', 'trending_feeds') }}

),

deduplicated as (

    select *,
        row_number() over (partition by id order by id) as row_num

    from source

),

final as (

    select
        id                                              as podcast_id,
        title,
        url,
        description,
        author,
        nullif(lower(split_part(split_part(language, '-', 1), '_', 1)), '') as language,
        itunes_id,
        trend_score,
        to_timestamp(newest_item_publish_time)::date   as newest_item_date

    from deduplicated
    where row_num = 1

)

select * from final