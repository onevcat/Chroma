import Testing
@testable import Chroma

@Suite("Golden - Dockerfile")
struct DockerfileGoldenTests {
    @Test("From instructions")
    func fromInstructions() throws {
        try assertGolden(
            "FROM ubuntu:22.04",
            language: .dockerfile,
            expected: [
                ExpectedToken(.keyword, "FROM"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "ubuntu"),
                ExpectedToken(.operator, ":"),
                ExpectedToken(.number, "22.04"),
            ]
        )
    }

    @Test("Run commands")
    func runCommands() throws {
        try assertGolden(
            "RUN echo \"hi\"",
            language: .dockerfile,
            expected: [
                ExpectedToken(.keyword, "RUN"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "echo"),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"hi\""),
            ]
        )
    }

    @Test("Env variables")
    func envVariables() throws {
        try assertGolden(
            "ENV PATH=${PATH}",
            language: .dockerfile,
            expected: [
                ExpectedToken(.keyword, "ENV"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "PATH"),
                ExpectedToken(.operator, "="),
                ExpectedToken(.property, "${PATH}"),
            ]
        )
    }

    @Test("Comments")
    func comments() throws {
        try assertGolden(
            "# note",
            language: .dockerfile,
            expected: [
                ExpectedToken(.comment, "# note"),
            ]
        )
    }
}
