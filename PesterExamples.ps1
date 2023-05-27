<#
Documentation: https://pester.dev/docs/quick-start
Install latest version: Install-Module Pester -Force -SkipPublisherCheck
    Note: May install a new version side by side a version you already have.
Check versions of pester installed: Get-Module -ListAvailable
Import Module: Import-Module Pester -Passthru 
    Note: Make sure it imported the latest version.
Formatting: Must use One True Brace Style
Assertion reference: https://pester.dev/docs/assertions/
Running tests: Invoke-Pester -Path C:\path.ps1 -Output Detailed
Test only specific blocks by tagging them and using the tag parameter with Invoke-Pester.
#>


<#
Nutshell example:

Describe 'Some function'
    Context 'When passing a string'
        It Should 'return a new string'

This is inspired by behavior driven development: https://en.wikipedia.org/wiki/Behavior-driven_development
Scenario: Name of scenario / use case
Given (Describe): the initial context at the beginning of the scenario, in one or more clauses;
When (Context): the event that triggers the scenario;
Then (It Should): the expected outcome, in one or more clauses.

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

BeforeAll {
    # BeforeAll runs once at the beginning of the file
    # To import file with code to test, use dot sourcing: . $PSScriptRoot/File-Name.ps1
    function Get-Planet ([string]$Name = '*') {
        $planets = @(
            @{ Name = 'Mercury' }
            @{ Name = 'Venus'   }
            @{ Name = 'Earth'   }
            @{ Name = 'Mars'    }
            @{ Name = 'Jupiter' }
            @{ Name = 'Saturn'  }
            @{ Name = 'Uranus'  }
            @{ Name = 'Neptune' }
        ) | ForEach-Object { [PSCustomObject] $_ }

        $planets | Where-Object { $_.Name -like $Name }
    }
}

Describe 'Get-Planet' {

    BeforeEach {
        # BeforeEach runs once before each test (It block) within the current Context or Describe block.
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
}

AfterAll {
    # Runs once at the end of the file
}