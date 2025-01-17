# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Pull Request Process

- Ensure any install or build dependencies are added to the pubspec.yaml.
- Update the README.md with details of changes, this includes new environment variables, exposed ports, useful file locations and container parameters.
- Increase the version numbers in ``project.pbxproj`` for iOS and in ``pubspec.yaml`` files and the README.md to the new version that this Pull Request would represent. The versioning scheme we use is SemVer.
- You may merge the Pull Request if you have the permissions and another reviewer approved, or if you do not have permission to do that, you may request the second reviewer to merge it for you.

## Code Style
To be able to keep up good code quality we agreed to ensure some code style principles:

1. Maximum file size is 300 lines =>  as soon as the size exceeds we try to outsource parts to separate files and refactor
2. Keep UI and Logic separated => Views should contain minimal logical code and Bloc shouldn't contain any UI parts
3. UI changes shouldn't affect Bloc changes => Changes on UI shouldn't provoke changes on Bloc implementation
4. BLoC events can only be emitted from methods inside screen and not nested widgets
5. Reusable widgets with state not contained a logic should manage it also internally
6. try to use not nullable type where possible
7. keep every part as simple as possible => no "over-engineering" or complicating
8. make adaptive widgets replaceable for future implementations from Flutter
9. limit the dependencies to a minimum - only include them if there isn't a simpler solution
10. make common widgets reusable with minimum configuration
11. strip assets to the required size (Icon-Sets)
12. try to use only standard widgets from Flutter where it's possible

## Restrictions

This application aims to stay as free as possible of any data requesting and advertising.
Any contributions violating this restriction wont be accepted.

## Code of Conduct
### Our Pledge

In the interest of fostering an open and welcoming environment, we as contributors and maintainers pledge to making participation in our project and our community a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

Examples of behavior that contributes to creating a positive environment include:

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

Examples of unacceptable behavior by participants include:

- The use of sexualized language or imagery and unwelcome sexual attention or advances
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information, such as a physical or electronic address, without explicit permission
- Other conduct which could reasonably be considered inappropriate in a professional setting

### Our Responsibilities

Project maintainers are responsible for clarifying the standards of acceptable behavior and are expected to take appropriate and fair corrective action in response to any instances of unacceptable behavior.
Project maintainers have the right and responsibility to remove, edit, or reject comments, commits, code, wiki edits, issues, and other contributions that are not aligned to this Code of Conduct, or to ban temporarily or permanently any contributor for other behaviors that they deem inappropriate, threatening, offensive, or harmful.

### Scope

This Code of Conduct applies both within project spaces and in public spaces when an individual is representing the project or its community. Examples of representing a project or community include using an official project e-mail address, posting via an official social media account, or acting as an appointed representative at an online or offline event. Representation of a project may be further defined and clarified by project maintainers.

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting the project team at info@mathema.de. All complaints will be reviewed and investigated and will result in a response that is deemed necessary and appropriate to the circumstances. The project team is obligated to maintain confidentiality with regard to the reporter of an incident. Further details of specific enforcement policies may be posted separately.
Project maintainers who do not follow or enforce the Code of Conduct in good faith may face temporary or permanent repercussions as determined by other members of the project's leadership.

### Attribution

This Code of Conduct is adapted from the Contributor Covenant, version 1.4, available at http://contributor-covenant.org/version/1/4
