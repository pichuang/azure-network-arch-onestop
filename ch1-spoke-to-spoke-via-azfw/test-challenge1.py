
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
        """
        Special HTTP/HTTPS website is reachable from Internet.
        azure.archive.ubuntu.com only support HTTP, not HTTPS.
        """
        azure_ubuntu_repo = self.host.addr("azure.archive.ubuntu.com")
        self.assertFalse(azure_ubuntu_repo.is_reachable)
        self.assertTrue(azure_ubuntu_repo.port(80).is_reachable)
        self.assertFalse(azure_ubuntu_repo.port(443).is_reachable)
        self.assertTrue(azure_ubuntu_repo.is_resolvable)

        azure_ubuntu_https = self.host.run("curl --connect-timeout 3 -o /dev/null -s -w %{http_code} https://azure.archive.ubuntu.com")
        self.assertNotEqual(azure_ubuntu_https.stdout, "200")

        azure_ubuntu_http = self.host.run("curl --connect-timeout 3 -o /dev/null -s -w %{http_code} http://azure.archive.ubuntu.com")
        self.assertEqual(azure_ubuntu_http.stdout, "200")

    def test_to_pypi(self):
        pypi = self.host.addr("pypi.org")
        self.assertTrue(pypi.is_reachable)
        self.assertTrue(pypi.port(80).is_reachable)
        self.assertTrue(pypi.port(443).is_reachable)
        self.assertTrue(pypi.is_resolvable)

        pypt_https = self.host.run("curl --connect-timeout 3 -o /dev/null -s -w %{http_code} https://pypi.org")
        self.assertEqual(pypt_https.stdout, "200")

    def test_to_pythonhosted(self):
        pythonhosted = self.host.addr("files.pythonhosted.org")
        self.assertTrue(pythonhosted.is_reachable)
        self.assertTrue(pythonhosted.port(80).is_reachable)
        self.assertTrue(pythonhosted.port(443).is_reachable)
        self.assertTrue(pythonhosted.is_resolvable)

        pypt_https = self.host.run("curl --connect-timeout 3 -o /dev/null -s -w %{http_code} https://files.pythonhosted.org")
        self.assertEqual(pypt_https.stdout, "200")

    def test_to_openai(self):
        openai = self.host.addr("www.openai.com")
        self.assertFalse(openai.is_reachable)
        self.assertFalse(openai.port(80).is_reachable)
        self.assertFalse(openai.port(443).is_reachable)
        self.assertFalse(openai.is_resolvable)

        pypt_https = self.host.run("curl --connect-timeout 3 -o /dev/null -s -w %{http_code} https://www.openai.com")
        self.assertNotEqual(pypt_https.stdout, "200")

if __name__ == "__main__":
    unittest.main()