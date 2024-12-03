#!/bin/bash

set -e

case "$1" in
    web)
        rake db:migrate
        exec puma
        ;;
    search)
        rake ts:configure
        exec rake ts:start
        ;;
    scheduler)
        exec clockwork config/clock.rb
        ;;
    worker)
        exec script/delayed_job.api.rb run
        ;;
    setup)
        # FIXME: Use db:prepare in Rails 5.
        # https://guides.rubyonrails.org/active_record_migrations.html#setting-up-the-database
        rake db:setup
        rake ts:index
        rake db:migrate
        ;;
    *)
        echo "error: Unrecognized service \"$1\"" >&2
        exit 1
        ;;
esac
