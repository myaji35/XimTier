class ApplicationJob < ActiveJob::Base
  retry_on Net::SMTPServerBusy,
           Errno::ECONNRESET,
           Errno::ECONNREFUSED,
           SocketError,
           Timeout::Error,
           wait: :polynomially_longer,
           attempts: 5 do |job, error|
    Rails.logger.error(
      "[JobFailure] job=#{job.class.name} arguments=#{job.arguments.inspect} " \
      "error=#{error.class}: #{error.message} retries_exhausted=true"
    )
  end

  rescue_from Net::SMTPAuthenticationError,
              Net::SMTPFatalError,
              Net::SMTPSyntaxError,
              Net::SMTPUnknownError do |error|
    Rails.logger.error(
      "[JobFailure] job=#{self.class.name} arguments=#{arguments.inspect} " \
      "error=#{error.class}: #{error.message} permanent=true"
    )
    raise error
  end

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
