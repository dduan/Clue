import SystemExit

#if canImport(Darwin)
import func Darwin.fputs
import var Darwin.stderr
#else
import func Glibc.fputs
import var Glibc.stderr
#endif

func bail(_ message: String) -> Never {
    fputs(message, stderr)
    exit(with: .failure)
}
