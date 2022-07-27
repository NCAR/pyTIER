# Git Workflow for TIER

> Note: This document has been conveniently adapted from the [Cookbook for working with Git and VIC](https://github.com/UW-Hydro/VIC/wiki/Git-Workflow) and the [SUMMA Git Workflow](https://github.com/NCAR/summa/blob/master/docs/development/SUMMA_git_workflow.md)

The basic workflow described here follows a workflow originally outlined by Vincent Driessen. The workflow is built around the Git version control system. A basic description of the branching strategy and release management used for TIER is presented here. We use a central truth repository (https://github.com/NCAR/TIER) that contains our main branches and the official release version of TIER. All active development takes place on forks and clones of this repo.

## Main Branches

There are two main branches: **master** and **develop**. The first one is the official release, the second one is the one undergoing active development.

 1. **master** -- The master branch represents the official release of the code. This branch is updated by new releases from the develop/release branches and by hotfixes. If you are not directly interested in model development, but want to use TIER for your own modeling project, then this is typically the branch that you want to use.

 2. **develop** -– The develop branch represents the bleeding edge of the code. We recommend that all new development begins by branching from the develop branch.

 Both of the main branches are published on the Github page and are controlled by the TIER admin group. The repository is organized into several branches for different purposes.

## Feature Branches

In general, any new feature branch should be based on the develop branch. Feature branches are used by developers to make self-contained changes to the TIER source code. Keeping the changes self-contained makes it much easier to merge new features into the main source code. For example, if you want to include new features consisting of a different runoff scheme and a new soil temperature scheme, you'd typically want to do that on two separate feature branches (or perhaps more). This will keep pull requests (to have your changes included in the main code) tractable. We merge completed feature branches into the develop branch for inclusion in the next release. A developer may have many feature branches, which may or may not be intended for inclusion in the main source code. Because context-switching is relatively easy with Git, the development of features using this strategy provides a clean and simple method for switching between features and the main branches during the development process.

## Admin Branches

Although anyone could create these branches, they are designed for the preparation of a release of the master branch or a hotfix that cannot wait to the next major release. These branches should therefore only be used by members of the admin group.

 1. **release** -– The release branch supports the preparation of a new release. It includes any changes needed for the next public release or minor bug fixes.

 2. **hotfix** -- The hotfix branch facilitates mid-release bug fixes of the master branch. The key point of the hotfix branch is that it does not incorporate any new features from the develop branch, rather it is a branch off the master that addresses a specific issue or set of issues. When the hotfix is applied, the development branch is updated to reflect the hotfix changes.

## Naming Conventions
 * Master branch – master
 * Develop branch – develop
 * Feature branch – feature/{feature_name}
 * Hotfix branch – hotfix/{hotfix_name}
 * Release branch – release/{release_name}
 * Release name – TIER.{major.minor.patch}

## User Permissions
Using Github to host the central or truth repository of our models allows us to easily control contributor permissions. Currently we split permission levels into 3 levels, Owners, Model Admins, and Developers.

 1. Owners have full access to all repositories and have admin rights to the organization.

 2. Model Admins have full access to specific repositories. They may push, pull, or make administrative changes to those repositories associated with their model. However, they should generally not push to the truth repo directly. Instead, they should fork, clone, edit locally, update their fork and then issue a pull request. This pull request should preferably be reviewed by someone else before it is merged.

 3. Developers have read-only access (pull, clone, fork) to the publicly listed repository. If a developer would like a feature branch merged into the main repository, a pull request must be submitted and a Model Admin may merge it in.

## Workflow examples

### New feature

You have developed a new geophysical weight influencing the spatial temperature distribution and would like to add this as a new process in TIER. We'll assume that you already have an account on GitHub and that you have the requisite software (Matlab or Octave) already installed.

The process would be as follows:

 * Navigate to the main [TIER repo](https://github.com/NCAR/TIER)

 * Fork the repo by clicking on the 'Fork' button in the upper right corner

 * Navigate to your fork

 * Clone the fork to your local machine

 * Add the main TIER repo as the upstream remote, so you can easily merge changes that are made in the main TIER repo into your own local repo

        git remote add upstream git@github.com:NCAR/TIER.git

 * Checkout the `develop` branch

        git checkout develop

 * Create and checkout the `feature/newWeight` branch (or whatever the appropriate name would be). If you create this branch while you are on the `develop` branch, the new branch will be based on `develop` (you can also specify this explicitly to git).

        git checkout -b feature/newWeight

 * Push this new branch to your remote on GitHub

        git push

 * Now make as many changes as you need to, commit them to your local repo and push them to your remote on GitHub. This is just like any other work you would do using Git. Once everything is working and everything is sufficiently tested, you will be ready to share your code with others.


 * Before you do that, merge any changes that have been made in the develop branch in the main TIER repo into the `feature/newWeight` branch of your local repo. Assuming you are already on the `feature/newWeight` branch:

        git fetch upstream
        git merge upstream/develop

 * Resolve any merge conflicts

 * Push your latest version to your remote on GitHub

 * Issue a pull request. You do that on GitHub. Make sure that you make the pull request with respect to the correct branches. On your end this should be the `feature/newWeight` branch and on the other end the `develop` branch.

 * Your changes will be reviewed and merged or more likely there will be some back-and-forth with suggested changes and clarifications.

