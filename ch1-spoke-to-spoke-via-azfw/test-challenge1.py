#!/usr/bin/env python3

"""
As a user, I want to be able to access the restricr internet and intranet from my Azure VM in spoke Azure VNet throught Azure Firewall
"""

import unittest
import testinfra

class TestNetworkRules(unittest.TestCase):
    """
    Test that the network rules are working as expected.
    """

    def setUp(self):
        self.host = testinfra.get_host("local://")

    def test_to_hub_vm(self):
        self.assertTrue(self.host.addr("10.73.30.164").is_reachable)

    def test_to_spoke1_vm(self):
        self.assertTrue(self.host.addr("10.73.31.4").is_reachable)

    def test_to_spoke2_vm(self):
        self.assertTrue(self.host.addr("10.73.33.4").is_reachable)

    def test_to_azfw(self):
        self.assertTrue(self.host.addr("10.73.30.4").is_reachable)

class TestApplicationRules(unittest.TestCase):
    """
    Test that the application rules are working as expected.
    """

    def setUp(self):
        self.host = testinfra.get_host("local://")

    def test_to_github(self):
        github = self.host.addr("github.com")
        self.assertTrue(github.is_resolvable)
        self.assertTrue(github.port(443).is_reachable)
        # self.assertFalse(github.is_reachable)

    def test_to_ifconfig_me(self):
        ifconfig_me = self.host.addr("ifconfig.me")
        self.assertTrue(ifconfig_me.is_resolvable)
        # self.assertFalse(ifconfig_me.is_reachable)

    def test_to_azure_ubuntu(self):
        ubuntu_repo = self.host.addr("azure.archive.ubuntu.com")
        self.assertTrue(ubuntu_repo.is_resolvable)
        # self.assertFalse(ubuntu_repo.is_reachable)

    def test_to_pypi(self):
        pypi = self.host.addr("pypi.org")
        self.assertTrue(pypi.is_resolvable)
        # self.assertFalse(pypi.is_reachable)

    def test_to_openai(self):
        openai = self.host.addr("www.openai.com")
        self.assertNotEqual(openai.run("wget www.openai.com").rc, 0)

if __name__ == "__main__":
    unittest.main()