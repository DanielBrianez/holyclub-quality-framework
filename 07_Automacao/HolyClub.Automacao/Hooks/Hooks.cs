using System.Threading.Tasks;
using Microsoft.Playwright;
using Reqnroll;
using Reqnroll.BoDi; // Importante para injetar a dependência

namespace HolyClub.Automacao.Hooks;

[Binding]
public class Hooks
{
    private readonly IObjectContainer _objectContainer;
    private IPlaywright _playwright= null!;
    private IBrowser _browser = null!;
    private IPage _page = null!;

    // O Reqnroll nos dá esse "container" para guardarmos coisas (como a página do navegador)
    public Hooks(IObjectContainer objectContainer)
    {
        _objectContainer = objectContainer;
    }

    [BeforeScenario]
    public async Task BeforeScenario()
    {
        // 1. Inicia o Playwright
        _playwright = await Playwright.CreateAsync();

        // 2. Abre o Navegador (Chromium)
        // Headless = false faz você VER o navegador abrindo. Se quiser rodar escondido, mude para true.
        _browser = await _playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
        {
            Headless = false, 
            SlowMo = 500 // Deixa um pouco mais lento para você ver as coisas acontecendo
        });

        // 3. Cria uma nova página (Aba)
        _page = await _browser.NewPageAsync();

        // 4. O PULO DO GATO:
        // Registra essa página no container para que o MatchmakingSteps consiga usá-la!
        _objectContainer.RegisterInstanceAs<IPage>(_page);
    }

    [AfterScenario]
    public async Task AfterScenario()
    {
        // Fecha tudo depois que o teste acabar para não travar o PC
        if (_browser != null)
        {
            await _browser.CloseAsync();
        }
        _playwright?.Dispose();
    }
}