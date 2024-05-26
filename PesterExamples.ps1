<#
Overview:

Documentation: https://pester.dev/docs/quick-start
Install latest version: Install-Module Pester -Force -SkipPublisherCheck
    Note: May install a new version side by side a version you already have.
Check versions of pester installed: Get-Module -ListAvailable
Import Module: Import-Module Pester -Passthru 
    Note: Make sure it imported the latest version.
Naming: ScriptToTest.Tests.ps1
Folder: Tests
Formatting: Must use One True Brace Style
Assertion reference: https://pester.dev/docs/assertions/
    -Be, -BeExactly (test for object equality), -Not -Be, -BeNullOrEmpty, -BeOfType, Throw
    -BeGreatherThan, -BeGreaterOrEqual, -BeLessThan, -BeLessOrEqual, -HaveCount
    -Contain (value present in collection), -BeIn (value present in collection), -BeLike (wildcard pattern), -Match (regex comparison)
Running tests: Execute file or use Invoke-Pester -Path C:\path.ps1 -Output Detailed
Tagging: Test only specific blocks by tagging them and using the tag parameter with Invoke-Pester.
Skipping: You can skip describe or context block with -skip operator. i.e. Describe "Some-Function" -Skip
Mocking reference: https://pester.dev/docs/usage/mocking
Mocking: Mock behavior of existing function with an alternate implementation. Mock FunctionToMock { # alternate implementaton }
#>

<#
Generic examples:

Describe 'Some function'
    Context 'When passing a string'
        It Should 'return a new string'

This is inspired by behavior driven development: https://en.wikipedia.org/wiki/Behavior-driven_development
Scenario: Name of scenario / use case
Given (Describe): the initial context at the beginning of the scenario, in one or more clauses;
When (Context): the event that triggers the scenario;
Then (It Should): the expected outcome, in one or more clauses.

You can have any number of describe, context, it, and should constructs.

Scenario 1: Items returned for refund should be added to inventory.
Given that a customer previously bought a black sweater from me
and I have three black sweaters in inventory,
when they return the black sweater for a refund,
then I should have four black sweaters in inventory.

Scenario 2: Exchanged items should be returned to inventory.
Given that a customer previously bought a blue garment from me
and I have two blue garments in inventory
and three black garments in inventory,
when they exchange the blue garment for a black garment,
then I should have three blue garments in inventory
and two black garments in inventory.
#>

<#
To import file with code to test, you can use dot sourcing: . $PSScriptRoot/File-Name.ps1
    When dot sourcing, entire script will be executed, consider commenting out main functionality.

A way to import functions from a script without executing it:
"
function Get-Functions($filePath)
{
    $script = Get-Command $filePath
    return $script.ScriptBlock.AST.FindAll({ $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] }, $false)
}

Get-Functions ScriptPath.ps1 | Invoke-Expression
"

Note this method probably doesn't work for scripts that contain class definitions.
#>

# template
BeforeAll {
    # Optional
    # BeforeAll runs once at the beginning of the file.

    function Get-Functions($filePath)
    {
        $script = Get-Command $filePath
        return $script.ScriptBlock.AST.FindAll({ $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] }, $false)
    }

    # $parentPath = ([IO.DirectoryInfo]$PSScriptRoot).Parent.FullName
    # $path = "$parentPath\scriptName.ps1"
    $path = # enter path of script to test (i.e, $PSScriptRoot\..\scriptName.ps1)
    Get-Functions $path | Invoke-Expression
}

Describe "Function-Name" {
    BeforeEach {
        # Optional
        # Runs once before each test (It block) within the current Describe or Context block.
    }

    Context "When passing a something" {
        It "Should do/return something" {
            # Pipe values you want to test to Should
            # i.e: $result | Should -Contain $expected
            # You can pipe to Should multiple times in an "It" block
        }
    }

    AfterEach {
        # Optional
        # Runs once after each test (It block) within the current Describe or Context block.
    }
}

AfterAll {
    # Optional
    # Runs once at the end of the file.
}

# detailed example
BeforeAll {
    # BeforeAll runs once at the beginning of the file
    # To import file with code to test, use dot sourcing: . $PSScriptRoot/File-Name.ps1
    # When dot sourcing, entire script will be executed, consider commenting out main functionality.
    function Get-Planet ([string]$Name = '*')
    {
        $planets = @(
            @{ Name = 'Mercury' }
            @{ Name = 'Venus' }
            @{ Name = 'Earth' }
            @{ Name = 'Mars' }
            @{ Name = 'Jupiter' }
            @{ Name = 'Saturn' }
            @{ Name = 'Uranus' }
            @{ Name = 'Neptune' }
        ) | ForEach-Object { [PSCustomObject] $_ }

        $planets | Where-Object { $_.Name -like $Name }
    }
}

Describe 'Get-Planet' {

    BeforeEach {
        # Optional
        # Runs once before each test (It block) within the current Describe or Context block.
    }

    Context 'No parameters' {
        It 'Given no parameters, it lists all 8 planets' {
            $allPlanets = Get-Planet
            $allPlanets.Count | Should -Be 8
        }

        It 'Earth is the third planet in our Solar System' {
            $allPlanets = Get-Planet
            $allPlanets[2].Name | Should -Be 'Earth'
        }

        It 'Pluto is not part of our Solar System' {
            $allPlanets = Get-Planet
            $plutos = $allPlanets | Where-Object Name -EQ 'Pluto'
            $plutos.Count | Should -Be 0
        }

        It 'Planets have this order: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune' {
            $allPlanets = Get-Planet
            $planetsInOrder = $allPlanets.Name -join ', '
            $planetsInOrder | Should -Be 'Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune'
        }
    }

    Context 'With -Filter' {
        It 'filters based on planet Name' {
            $expected = "Earth"
            $actual = Get-Planet "E*"
            $actual.Name | Should -Be $expected     
        }
    }

    AfterEach {
        # Optional
        # Runs once after each test (It block) within the current Describe or Context block.
    }
}

AfterAll {
    # Runs once at the end of the file
}