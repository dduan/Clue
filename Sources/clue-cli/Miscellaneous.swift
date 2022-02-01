#if canImport(Darwin)
import func Darwin.fputs
import func Darwin.exit
import var Darwin.EXIT_FAILURE
import var Darwin.stderr
#else
import func Glibc.fputs
import func Glibc.exit
import var Glibc.EXIT_FAILURE
import var Glibc.stderr
#endif

func bail(_ message: String) -> Never {
    fputs(message, stderr)
    exit(EXIT_FAILURE)
}
