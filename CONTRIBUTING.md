# SSECR Contributing Guidelines

## Editing Course Materials

There are three options for editing the course materials:

1. Send materials to Nick Lyon for integration into the website
2. Work directly in GitHub
    - only available if the page(s) you're editing <u>do not</u> have code chunks
3. Connect GitHub to your preferred code software (e.g., RStudio, VS Code, etc.) and push local changes to GitHub

### Avoiding Conflicts

If either option 2 or 3 sounds like a good fit for you, we need to be careful we do not cause merge conflicts! Please make a post in the `#lter-grad-course` channel of the NCEAS Slack organization for _both_ when you start working on the website _and_ when you're finished.

If you're working in a developer environment (i.e., option 3 above), please pull regularly so that you are editing the most up-to-date materials. 

At this point, we are **not** using GitHub branches and/or forks so please just work directly in the 'main' branch.

## Accessing Course Materials

### GitHub

We are using a GitHub Team (see [here](https://docs.github.com/en/organizations/organizing-members-into-teams/about-teams) for more information on GitHub Teams) to simplify access protocols to SSECR GitHub materials.

Contact Marty Downs and/or Nick Lyon to be added to the SSECR GitHub Team. This will give you _write-level access_ to (A) the [SSECR GitHub repository](https://github.com/lter/ssecr) and (B) the [SSECR GitHub Project](https://github.com/orgs/lter/projects/6) that we're using for task management.

### Shared Drive

Contact Marty Downs and/or Nick Lyon for access to the Google Drive. The Shared Drive is named "LTER-Grad-Course".

### Communication

Communicating via email is fine though we also have the `#lter-grad-course` channel in [NCEAS](https://www.nceas.ucsb.edu/)' Slack organization if that is preferable.

## Project Management

- Individual tasks should be tracked as [GitHub Issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/quickstart)
    - Be sure that each task is **S.M.A.R.T.** (i.e., specific, measurable, achievable, relevant, and time-bound)
- **Please use the issue template**
    - When you select "New Issue" you will be prompted to use this template automatically
- Try to document task progress within the dedicated issue for that task (for posterity)
- Strategic planning (i.e., project management across tasks) should use the [SSECR GitHub Project](https://github.com/orgs/lter/projects/6/views/1)
    - Task lifecycle can be tracked by dragging an issue's "card" among columns that correspond to major steps in task completion

## Style Guide

If you are directly contributing to the website, please try to use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) syntax in your commit messages so it is easy for others to identify the purpose and scope of changes made in each commit.

As much as possible, use snake case (i.e., all_lowercase_separated_by_underscores). When in doubt, try to maintain consistency with the naming convention and internal structure of other files in the same directory/repository.
