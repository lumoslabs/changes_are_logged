# 1.2.1
* Replace HashWithIndifferentAccess with ActiveSupport::HashWithIndifferentAccess.

# 1.2.0
* Add Rails 5 compatibility

# 1.1.0
* Don't monkey patch 'attribute_change' method from ActiveModel::Dirty

# 1.0.0
* Interface changed: call `automatically_log_changes` in your model instead of setting up an `after_initialize` callback.
* `automatically_log_changes` accepts a block to alter the values of logged attributes.

# 0.0.2
* Birthday
