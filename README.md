# fastlane-custom-actions

``` ruby
upload_to_obs(
    bucket: 'your-bucket-name',
    object_path: 'path'
)

notification(app_icon: './fastlane/icon.png', title: 'Fastlane: Upload To OBS successfully！🎉', subtitle: '', message: Actions.lane_context[SharedValues::OBS_IPA_OUTPUT_URL])
```