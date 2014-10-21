RSpec.configure do |config|
  # Enforce expect syntax.
  config.expect_with :rspec do |rspec|
    rspec.syntax = :expect
  end

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  # Exclude external tests by default.
  config.filter_run_excluding external: true

  # Raise errors for any deprecations.
  config.raise_errors_for_deprecations!
end
