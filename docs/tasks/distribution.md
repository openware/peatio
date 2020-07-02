## How to process distribution for users

1. Create `csv` files with those templates.

### Distribution table

  |      uid      | currency_id | amount |
  |---------------|-------------|--------|
  | ID1000003837  | usdt        |  100   |

  uid, currency_id, amount - require params

2. For process distribution
   
```ruby
   bundle exec rake distribution:process['file_name.csv']
```
